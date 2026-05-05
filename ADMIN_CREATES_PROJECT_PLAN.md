# Plano — Admin cria obras e fases; cliente recebe link, paga e valida

> Plano de implementação derivado do código atual (`ox-admin`, `ox-app-client`, `ox-backend`).
> Estimativas em **t-shirt size** (S ≤ 0,5 dia, M = 1–3 dias, L = 3–7 dias).
> Reaproveita autenticação Supabase + JWT, modelo `Project/ProjectPhase`, fluxo de pagamento/escrow e validação de fases já existentes.

---

## 0. Resumo da decisão

**Identificação do cliente (no admin):** usar o **email** como entrada principal, com fallback para **telefone** (`User.phone`). Justificação:
- O `User.email` já é `@unique` no schema (`ox-backend/prisma/schema.prisma`), garantindo idempotência ao reaproveitar clientes existentes.
- Telefone é prático na visita presencial, mas não é único no schema atual; serve como dado complementar e canal de envio do link (SMS/WhatsApp).
- Cliente pode **ainda não ter conta** → o admin cria/consulta um `User(role=client)` por email; o vínculo final ao `auth.users` (Supabase) só acontece quando o cliente faz `POST /auth/sync` no primeiro login.

**Mecanismo de partilha:** **token de convite assinado**, materializado num **deep link universal** (Android App Link + iOS Universal Link), com **fallback colável** num ecrã da app. Justificação:
- Magic link de auth (Supabase) **não basta**: precisamos de associar o cliente ao **projeto específico** que o admin criou na visita.
- Token próprio permite expirar, revogar, ser usado uma vez e funcionar mesmo se o cliente ainda não tem conta.

**Quem cria o projeto:** apenas `admin`. O endpoint passa a aceitar `clientId` (ou `clientEmail`) no body quando `role=admin`. O caminho atual em que o serviço usa `appUser.id` como `clientId` é mantido só para retrocompatibilidade enquanto a UI no Flutter não for removida (ver Marco 4).

**Quem paga e valida fases:** continua a ser o cliente. Sem alterações no fluxo de pagamento/escrow nem na validação de fases (já hoje em `phases.service.ts`).

---

## 1. Marcos ordenados (alto nível)

| # | Marco | Tamanho | Depende de |
|---|-------|---------|------------|
| **M1** | Backend: criar projeto em nome de cliente + endpoint de "buscar/criar cliente" | **M** | — |
| **M2** | Backend: tabela e endpoints de **convites** (`ProjectInvite`) com token + expiração | **M** | M1 |
| **M3** | Admin web: ecrã de criação de obra (cliente + fases + orçamento) e ecrã de gestão de convites/link | **M–L** | M1, M2 |
| **M4** | App mobile: ecrã "Adicionar obra por link" + handler de deep link + remoção do fluxo de criação | **M** | M2 |
| **M5** | Deep links nativos (Android App Links + iOS Universal Links) | **M** | M2 |
| **M6** | Permissões/state-machine: alinhar transições e quem inicia o pagamento | **S–M** | M1 |
| **M7** | Testes (unit, e2e API, integração admin/app) e telemetria/observabilidade dos convites | **M** | M1–M6 |
| **M8** | Documentação + migração de dados (projetos antigos com `clientId = admin`?) | **S** | M1 |

---

## 2. Marco 1 — Backend: criação de obra em nome do cliente · **M**

### Endpoints (alterações)

- **`POST /projects`** — controller `ox-backend/src/modules/projects/projects.controller.ts`
  - Hoje: `@Roles('client', 'admin')`, `service.create(userKey, dto)` força `clientId = appUser.id`.
  - Novo: aceitar `clientId` no DTO **apenas quando** `req.user.role === 'admin'`. Restrição opcional: bloquear `client` no futuro (feature flag `ALLOW_CLIENT_PROJECT_CREATION=false`).
- **`POST /admin/clients/lookup-or-create`** *(novo)* — só `admin`, body `{ email, name?, phone? }`, devolve `{ id, role, isNew }`. Usa `prisma.user.upsert` por `email`. Cria com `role=client` e `authId` provisório (ex.: `pending:<uuid>`); no primeiro `POST /auth/sync` do cliente, atualizar `authId` real (já há lógica em `auth.service.ts`, ajustar para reaproveitar pelo email).
- **`PATCH /projects/:id`** — `ProjectsService.update` hoje exige `project.clientId === appUser.id`. Adicionar exceção para `role=admin`.
- **`DELETE /projects/:id`** — idem; admin pode remover rascunhos.

### DTOs

- `CreateProjectDto` ganha `clientId?: string` (UUID) **OU** `clientEmail?: string`. Validação: pelo menos um deles quando o requisitante é admin; ignorado quando `client`.
- Novo `LookupOrCreateClientDto { email: string; name?: string; phone?: string }`.

### Autorização

- `RolesGuard` mantém-se. Mover a verificação "quem pode setar `clientId`" para o serviço para conseguir 403 explícito ("apenas admin pode criar em nome de outro cliente").

### Critérios de aceitação

- Admin autenticado consegue `POST /projects { clientEmail, title, budget, location, phases: [...] }` e o projeto fica com `clientId` correto e `status=draft`.
- Admin não consegue editar projetos de outro cliente apenas se for `admin` *(deve conseguir; teste valida que consegue)*.
- Cliente continua a poder listar **só os seus** projetos (filtro `req.user.role === 'client'` em `findAll` mantém-se).
- Erro 400 claro quando admin omite `clientId`/`clientEmail`.

---

## 3. Marco 2 — Backend: convites com token · **M**

### Modelo de dados (novo)

```prisma
model ProjectInvite {
  id          String       @id @default(uuid())
  projectId   String
  project     Project      @relation(fields: [projectId], references: [id])
  clientId    String       // User com role=client (pode ser stub criado em M1)
  client      User         @relation(fields: [clientId], references: [id], name: "ClientInvites")
  tokenHash   String       @unique // SHA-256 do token; nunca guardar plaintext
  expiresAt   DateTime
  usedAt      DateTime?
  revokedAt   DateTime?
  createdById String       // admin que emitiu
  createdAt   DateTime     @default(now())

  @@index([projectId])
  @@index([clientId])
}
```

> Ajustar `User.projects` para suportar a back-relation nomeada (`ClientInvites`).

### Endpoints

- **`POST /projects/:id/invites`** *(admin)* → cria convite, devolve **uma única vez** o token plaintext + URL completa (`https://app.ox.example/i/<token>`), guarda apenas `tokenHash`. Default `expiresAt = now + 14 dias`.
- **`GET /projects/:id/invites`** *(admin)* → lista convites do projeto (sem expor token).
- **`DELETE /invites/:id`** *(admin)* → marca `revokedAt`.
- **`POST /invites/redeem`** *(client autenticado)* → body `{ token }`. Faz:
  1. `tokenHash = sha256(token)`
  2. Procura convite válido (`!usedAt`, `!revokedAt`, `expiresAt > now`).
  3. Se `invite.clientId.email !== req.user.email` → ainda assim aceita (cenário em que o cliente fez sign-up com email diferente do que o admin colocou) **mas** apenas se o admin tiver marcado `allowAnyEmail` ou se o stub não tiver `authId` real ainda; caso contrário 403.
  4. Faz `merge`/`reassign`: se o cliente já tinha um `User` real, transfere `Project.clientId` para o `User` autenticado e desativa o stub; se o stub é o próprio (após `auth/sync` casar pelo email), só marca `usedAt`.
  5. Marca `usedAt = now`.
  6. Devolve `{ projectId }` para o app navegar.
- **`GET /invites/preview?token=...`** *(público, rate-limit)* → devolve **só** `{ projectTitle, clientName, expiresAt }` para mostrar antes do login. Não revela `clientId` nem fases.

### Regras de segurança

- **Token**: 32 bytes random (`crypto.randomBytes`), base64url. Nunca em logs.
- **Hash**: SHA-256 (sem salt necessário; entropia do token chega).
- **Rate-limit**: `redeem` e `preview` com `@nestjs/throttler` (ex.: 10/min/IP).
- **Single-use** + **expiração** + **revogação manual**.
- Quando partilhado: cobre-se com single-use + auditoria (`createdById`, `usedAt` permitem rastrear).

### Critérios de aceitação

- Admin gera link e a tabela tem `tokenHash`, nunca o plaintext.
- Cliente autenticado faz `redeem` e o projeto aparece em `GET /projects` (filtro client).
- Token reutilizado → 410 Gone.
- Token expirado → 410 Gone.
- Token revogado → 403.
- `preview` não expõe dados sensíveis.

---

## 4. Marco 3 — Admin web: criação e gestão de obras · **M–L**

### Ecrãs novos / alterados (`ox-admin/app/[locale]/(dashboard)/`)

1. **`projects/new/page.tsx`** *(novo)* — formulário multi-step parecido com o do Flutter:
   - Step 1: identificar cliente (input email + botão "buscar/criar"; mostra `name`, `phone`, badge `existente`/`novo`).
   - Step 2: dados da obra (`title`, `location`, `budget`, `deadline`).
   - Step 3: fases dinâmicas (nome, ordem, valor); soma das fases = orçamento (validação suave, alerta).
   - Step 4: revisão + "Criar e gerar link".
2. **`projects/[id]/page.tsx`** *(alterar)* — secção **Convite ao cliente**:
   - Botão "Gerar link" (chama `POST /projects/:id/invites`).
   - Mostra **apenas uma vez** o link completo (com botão copiar).
   - Lista de convites: estado (ativo / usado / expirado / revogado), criado por, data, botão revogar.
   - Botões opcionais: `mailto:` pré-preenchido, `wa.me/<phone>?text=...` para WhatsApp.
3. **`components/features/projects/CreateProjectForm.tsx`** *(novo)*.
4. **`components/features/projects/InvitePanel.tsx`** *(novo)*.

### Queries novas (`ox-admin/lib/queries/`)

- `useCreateProject` (POST /projects).
- `useLookupOrCreateClient`.
- `useProjectInvites(projectId)`, `useCreateInvite`, `useRevokeInvite`.

### Sidebar / navegação

- `ox-admin/components/layout/Sidebar.tsx`: botão "Nova obra" no topo da lista de projetos.

### Critérios de aceitação

- Admin completa o formulário e vê toast com link copiável.
- Lista de convites refresca após gerar/revogar.
- I18n: chaves novas em `ox-admin/messages/{en,pt,es,nl}.json` (manter consistência com `I18N_PLAN.md`).

---

## 5. Marco 4 — App mobile (Flutter): receber convite · **M**

### Ecrã "Adicionar obra por link"

- **Local**: novo botão no `projects_list_screen.dart` (substitui o botão "Nova obra" que apontava para `/projects/new`).
- **Rota nova**: `/redeem` em `app_router.dart`.
- **UX**:
  - Campo de texto (paste).
  - Detecção automática de URL no clipboard (oferecer "Colar link copiado").
  - Botão "Validar". Mostra preview (título, expiração) via `GET /invites/preview`.
  - Botão "Adicionar à minha conta" → `POST /invites/redeem` → navega para `/projects/:id`.
  - Tratamento de erros: expirado, revogado, "este link é para outro email" (mensagem dizendo para entrar com o email correto).

### Remover criação de obra no app

- Apagar rota `/projects/new`, ecrã `create_project_screen.dart`, e métodos `create`/`createAndSubmit` em `project_provider.dart`.
- Limpar strings em `lib/l10n/app_*.arb` (manter chaves para histórico ou remover).

### Riverpod / API

- `inviteProvider` com `preview(token)` e `redeem(token)`.
- Constantes em `api_endpoints.dart`: `invitesPreview`, `invitesRedeem`.

### Critérios de aceitação

- Cliente sem obra cola um link válido e vê a obra na lista.
- Clipboard auto-detect: ao abrir o ecrã com URL `https://app.ox.example/i/...` no clipboard, o campo já vem preenchido.
- Token inválido → mensagem amigável e botão "Tentar de novo".
- Não há rota de criação de projeto exposta ao cliente.

---

## 6. Marco 5 — Deep links nativos · **M**

### Esquema de URL

- Universal: `https://app.ox.example/i/<token>`
- Custom scheme (debug/fallback): `oxapp://i/<token>`
- Backend serve `apple-app-site-association` e `assetlinks.json` em `https://app.ox.example/.well-known/`.

### Android (App Links)

- `ox-app-client/android/app/src/main/AndroidManifest.xml`: `intent-filter` com `android:autoVerify="true"`, `data android:scheme="https" android:host="app.ox.example" android:pathPrefix="/i"` (e duplicado para `oxapp://`).
- `assetlinks.json` com SHA-256 do certificado (debug e release).

### iOS (Universal Links)

- `ox-app-client/ios/Runner/Runner.entitlements` com `com.apple.developer.associated-domains = ["applinks:app.ox.example"]`.
- `apple-app-site-association` com `appID = TEAMID.com.ox.app`.

### Flutter

- Pacote `app_links` (ou `uni_links`) para escutar links de cold-start e em foreground.
- Listener no `app.dart` (root) que faz `router.go('/redeem?token=...')`.

### Como testar em dev

- **Android**:
  - `adb shell am start -W -a android.intent.action.VIEW -d "https://app.ox.example/i/TESTTOKEN" com.ox.app`
  - Para custom scheme: `adb shell am start -W -a android.intent.action.VIEW -d "oxapp://i/TESTTOKEN"`
- **iOS Simulator**:
  - `xcrun simctl openurl booted "https://app.ox.example/i/TESTTOKEN"`
- **Web preview** (admin): pode-se navegar com browser; se a app não estiver instalada, a página deve oferecer link da loja (página estática hospedada no admin).

### Critérios de aceitação

- App fechada + clicar no link no email → abre direto em `/redeem` com token preenchido.
- App em background → mesma coisa, sem perder estado.
- App não instalada → página web mostra "instala a app" (S, pode ser uma página estática).

---

## 7. Marco 6 — Permissões e state-machine · **S–M**

- **`SUBMIT`**: hoje permitido a `client` (dono) ou `admin`. Manter, mas definir que **o admin** chama `SUBMIT` automaticamente após criar (parâmetro `submit=true` no `POST /projects`) ou deixar manual no painel. Recomendado: `submit=true` por defeito quando admin cria pós-visita (já saí do "rascunho").
- **`APPROVE`/`REJECT`**: continuam só admin. Sem alteração.
- **`PAY`**: chamado a partir do app cliente quando o pagamento Stripe é confirmado. Sem alteração na regra de role; apenas verificar que o `redeem` precede o pagamento (UI no app só mostra "Pagar" depois de o projeto estar na conta do cliente).
- Confirmar que **`update`** (`PATCH /projects/:id`) e fases (no futuro: editar fases) **só permitem admin** quando o projeto estiver pós-`draft`.

### Critérios de aceitação

- Tabela de transições documentada no README do backend (atualizar `ox-passo-a-passo.md`).
- Testes e2e cobrem cada role × evento.

---

## 8. Marco 7 — Testes e observabilidade · **M**

### Backend (`ox-backend`)

- Unit (`projects.service.spec.ts`): admin cria com `clientEmail` novo / existente; cliente não pode passar `clientId` de outro.
- Unit (`invites.service.spec.ts`): hash, expiração, single-use, revogação, redeem com email diferente.
- E2E (`test/`): fluxo completo admin → invite → cliente login → redeem → list projects → pay → validate phase.

### Admin (`ox-admin`)

- Playwright/RTL: criar projeto end-to-end, gerar link, revogar.

### App (`ox-app-client`)

- Widget tests do `RedeemScreen`.
- Integration test com `app_links` mockado.

### Observabilidade

- Logger estruturado nos handlers de invite (`invite.created`, `invite.redeemed`, `invite.expired`).
- Métrica simples: contador de `redeem_success` / `redeem_fail` por motivo (já há `EventEmitter2` no projeto).

---

## 9. Marco 8 — Migração e docs · **S**

- Script SQL (Prisma migration) para adicionar `ProjectInvite`.
- Documentar em `docs/admin-creates-project.md` (novo) e linkar de `README.md`.
- Atualizar `ox-passo-a-passo.md` com o novo fluxo.
- Decidir o que fazer com **projetos `draft` órfãos** criados pelo cliente em versões anteriores: opção mais simples é mantê-los e só desativar a UI nova de criação no app.

---

## 10. Resumo de alterações por área

### API (resumo)

| Método | Caminho | Role | Estado |
|--------|---------|------|--------|
| POST | `/admin/clients/lookup-or-create` | admin | **novo** |
| POST | `/projects` | admin (client em retrocompat) | **alterado** (aceita `clientEmail`/`clientId`) |
| PATCH | `/projects/:id` | admin OR dono | **alterado** (admin pode) |
| POST | `/projects/:id/invites` | admin | **novo** |
| GET | `/projects/:id/invites` | admin | **novo** |
| DELETE | `/invites/:id` | admin | **novo** |
| GET | `/invites/preview` | público (rate-limit) | **novo** |
| POST | `/invites/redeem` | client | **novo** |

### Modelo

- Novo: `ProjectInvite` (token hashed + expiração + uso).
- Pequeno ajuste: `User` ganha relação reversa para convites.
- (Opcional) `User.authId` passa a aceitar valores `pending:*` para stubs criados pelo admin antes do primeiro login.

### UI

- **Admin**: `projects/new`, painel de convites em `projects/[id]`, formulário de "lookup/cria cliente".
- **App**: ecrã `RedeemScreen`, listener de deep link, remoção do `CreateProjectScreen`.

---

## 11. Matriz de riscos

| # | Risco | Severidade | Probabilidade | Mitigação |
|---|-------|-----------|----------------|-----------|
| R1 | Token vazado por logs / screenshots | Alta | Média | Hash em DB; sem log do plaintext; só single-use; expiração curta (14 dias). |
| R2 | Cliente sem conta no momento do convite | Média | Alta | Stub `User` com `authId='pending:<uuid>'`; `auth/sync` faz reconciliação por email. |
| R3 | Cliente cria conta com email diferente do que o admin colocou | Média | Média | Permitir `redeem` se o stub ainda for `pending`; caso contrário, mensagem clara para usar email correto. Admin pode reemitir convite com email atualizado. |
| R4 | Link expirado ou revogado | Baixa | Alta | Mensagem amigável + botão "pedir novo link" (gera notificação ao admin). |
| R5 | Deep link em iOS sem `apple-app-site-association` correto não abre a app | Alta | Média | Testar em TestFlight cedo; documentar; manter custom scheme `oxapp://` como fallback. |
| R6 | Admin cria fases com soma ≠ orçamento | Baixa | Média | Validação no formulário + warning não-bloqueante; backend não força (já hoje não força). |
| R7 | Admin esquece de marcar `SUBMIT` e o projeto fica em `draft` | Média | Média | Default `submit=true` ao criar pelo admin; toggle visível no formulário. |
| R8 | Conflito de roles: cliente vê obra mas não consegue pagar | Alta | Baixa | Garantir que `redeem` reatribui `clientId` para o `User` real antes de qualquer transição de pagamento. |
| R9 | Migração quebra projetos antigos | Média | Baixa | Manter `POST /projects` com path antigo para `client` atrás de feature flag até confirmar. |
| R10 | Throttling insuficiente no `preview` permite enumeration | Média | Baixa | Rate-limit + tokens longos (32 bytes); resposta genérica para token inválido vs expirado. |

---

## 12. Estimativa total

- **Backend (M1+M2+M6+M7 parte API)**: ~5–7 dias.
- **Admin (M3)**: ~3–5 dias.
- **App (M4+M5)**: ~4–6 dias.
- **Testes/docs (M7+M8)**: ~2–3 dias.
- **Total**: ~2 a 3 semanas para um dev focado, ou ~1 semana se paralelizado entre 2–3 pessoas (1 backend, 1 admin, 1 mobile).

---

## 13. Ordem recomendada de execução

1. M1 (backend `clientId` no admin) — destrava todo o resto.
2. M2 (invites) em paralelo com M3 (admin form de criação).
3. M3 painel de convites assim que M2 estiver pronto.
4. M4 (app: redeem) atrás de mock se M2 atrasar.
5. M5 (deep links nativos) — pode ir em paralelo com M4.
6. M6 (permissões) — pequeno trabalho de polish, fechar gaps.
7. M7 (testes) — em cada PR, mas com sprint final dedicado.
8. M8 (docs/migração) — antes do release.

---

## 14. Open questions para o produto

1. O cliente pode ter **vários convites pendentes** ao mesmo tempo? (Sugestão: sim, um por projeto.)
2. Após `redeem`, o cliente pode **rejeitar** o projeto ou só seguir para pagamento?
3. O admin precisa de poder **editar fases** depois de criar (e antes do cliente pagar)? Hoje o `UpdateProjectDto` omite `phases`; pode ser preciso novo endpoint `PUT /projects/:id/phases` (admin only, só em `draft`/`in_validation`).
4. Notificação push ao admin quando o convite é resgatado/expira? (Recomendado, reusar `NotificationsService`.)
5. Política de retenção: convites usados/revogados ficam quanto tempo na tabela? (Sugestão: 90 dias e arquivar.)
