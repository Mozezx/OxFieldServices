# OX Field Service — Contexto Completo da Sessão
> Documento gerado para continuidade do desenvolvimento em outros ambientes (Claude Code, Roo Code, etc.)
> Contém todas as decisões, arquitetura, stack e outputs desta sessão de trabalho.

---

## 1. O Projeto — Visão Geral

**Nome:** OX Field Service (parte do OX Group Ecosystem)
**Tipo:** Sistema operacional da construção — não é um app simples
**Origem:** Documento de requisitos do sócio (em holandês/flamengo)
**Desenvolvedor:** Solo dev com vibe coding
**Status atual:** Autenticação delegada ao Supabase — em desenvolvimento

### Problema que resolve

A construção civil belga tem 3 problemas estruturais:
1. Trabalho informal e sem rastreabilidade
2. Pagamentos sem garantia para nenhuma das partes
3. Qualidade de execução sem comprovação

### Solução OX

| Pilar | Como resolve |
|---|---|
| Workforce Control | Trabalhadores certificados via Shelter (ASBL/ONG) |
| Payment Control | Escrow obrigatório — Stripe Connect — dinheiro bloqueado até validação |
| Quality Control | Foto/vídeo obrigatórios por fase — sem evidência = sem pagamento |

---

## 2. Os 3 Produtos do Ecossistema

```
OX ECOSYSTEM
├── OX Field Service    → plataforma de gestão de projetos + pagamentos
├── OX Materials Hub    → supply chain centralizado (Fase 2 / pós-MVP)
└── Shelter             → certificação e integração de trabalhadores (ONG)
```

---

## 3. Stack Tecnológica — Decisão Final

| Camada | Tecnologia | Justificativa |
|---|---|---|
| App cliente | Flutter | Solo dev — 1 codebase para iOS/Android |
| App trabalhador | Flutter | Mesmo ecossistema |
| Web admin OX | React + TypeScript | Interface de gestão |
| Backend API | NestJS + TypeScript | Modular, enterprise, fácil DDD |
| Banco principal | PostgreSQL | ACID obrigatório para escrow |
| Auth | **Supabase Auth** ← já implementado | Delegado ao Supabase |
| Storage (fotos/vídeos) | Supabase Storage | Integrado ao mesmo ecossistema |
| Realtime | Supabase Realtime | Status ao vivo sem WebSocket custom |
| Cache + Filas | Redis + BullMQ | Processamento de eventos assíncrono |
| Pagamentos | Stripe Connect + Mollie | Split automático nativo |
| Push notifications | Firebase Cloud Messaging | — |
| Chat (se precisar) | Stream Chat | NÃO construir do zero |
| Deploy | Railway (backend) + Vercel (admin) | Custo mínimo, zero DevOps |
| Containerização | Docker + Docker Compose | Dev local + produção |
| CI/CD | GitHub Actions | Push → deploy automático |
| Monitoramento | Sentry + Logtail | Erros + logs |

---

## 4. Arquitetura — Modular Monolith (DECISÃO CRÍTICA)

**Zero microservices no MVP.** Microservices solo = morte certa.

Estrutura de pastas do backend:

```
/src
  /modules
    /auth              ← JWT + RBAC (integrado com Supabase Auth)
    /users             ← cliente, trabalhador, admin
    /projects          ← criação, validação, status
    /phases            ← fases, checklists, evidências
    /matching          ← algoritmo de seleção de workers
    /contracts         ← contratos digitais
    /escrow            ← pagamentos bloqueados
    /payments          ← liberação, split, Stripe Connect
    /materials         ← Materials Hub (Fase 2 — pós-MVP)
    /notifications     ← FCM + eventos
  /common
    /state-machine     ← XState — estados do sistema
    /events            ← BullMQ event bus
    /guards            ← RBAC guards
    /interceptors      ← logging, idempotência
```

### Princípios de engenharia aplicados

- **DDD (Domain-Driven Design):** organização por domínio de negócio
- **Clean Architecture:** domínio / aplicação / infraestrutura separados
- **Event-Driven (leve):** BullMQ + Redis para desacoplar módulos
- **State Machine (XState):** estados explícitos — crítico para escrow
- **API-First:** OpenAPI/Swagger antes de codificar
- **Repository Pattern:** isolamento do banco para testabilidade

---

## 5. State Machine — O Núcleo do Sistema

**Regra inviolável:** pagamento só é liberado quando `phase.status === "validated"`

### Estados do Projeto

```
draft → in_validation → matched → contract_signed
     → active_escrow → in_execution → closing → closed
                                    ↕
                               rejected (volta para in_execution)
```

### Estados de Fase

```
pending → in_progress → evidence_uploaded
       → under_review → validated  ← único estado que libera pagamento
                     → rejected (volta para in_progress)
```

### Biblioteca: XState (TypeScript)

---

## 6. Banco de Dados — Schema Core (Prisma)

```prisma
enum UserRole        { client worker admin }
enum ProjectStatus   { draft in_validation matched contract_signed active_escrow in_execution closing closed rejected }
enum PhaseStatus     { pending in_progress evidence_uploaded under_review validated rejected }
enum EscrowStatus    { held released refunded }

model User           { id, role, name, email, phone, password, createdAt }
model Worker         { id, userId, skills[], rating, shelterCertified, available }
model Project        { id, clientId, status, title, budget, location, deadline }
model ProjectPhase   { id, projectId, name, status, order, amount }
model PhaseEvidence  { id, phaseId, type, url, uploadedBy, uploadedAt }
model Contract       { id, projectId, workerId, totalAmount, stripeIntentId }
model EscrowTxn      { id, contractId, amount, status, releasedAt }
model Payment        { id, escrowId, recipientType, recipientId, amount, stripeTransferId }
model WorkerRating   { id, workerId, projectId, score, feedback }
```

### Materials Hub (Fase 2)

```prisma
model Material       { id, name, category, supplierId, price, sku }
model Supplier       { id, name, rating, responseTimeAvg, active }
model Order          { id, projectId, phaseId, supplierId, status, deliveryAt }
model OrderItem      { id, orderId, materialId, quantity, unitPrice }
model Delivery       { id, orderId, scheduledAt, deliveredAt, proofUrl }
```

---

## 7. Stripe Connect — Split Automático

```
Pagamento cliente: €1.000 (100%)
    │
    ├── Trabalhador   → €700 (70%) — transfer automático
    ├── Fornecedor    → €200 (20%) — transfer automático
    └── OX Commission → €100 (10%) — retido na plataforma
```

**Por que Stripe Connect e não Stripe normal?**
Stripe Connect é o único que faz o split automático e atômico — sem código manual de distribuição.

**Regras de segurança invioláveis:**
- Nunca processar pagamento no frontend
- Sempre validar webhook com assinatura (`stripe-signature`)
- Sempre usar idempotency key em transfers
- Transações ACID para toda operação de escrow

---

## 8. Autenticação — Supabase Auth (JÁ IMPLEMENTADO)

**Decisão:** Autenticação delegada ao Supabase Auth.

O que isso significa na prática:
- Registro/login gerenciado pelo Supabase
- JWT emitido pelo Supabase — validado no NestJS via `@supabase/supabase-js`
- RBAC (client / worker / admin) implementado via custom claims no JWT ou tabela `users` local
- Refresh tokens gerenciados pelo Supabase
- Recuperação de senha via Supabase

O NestJS recebe o JWT do Supabase e valida com o guard:

```typescript
// Fluxo:
// 1. Flutter/React → POST Supabase Auth → recebe JWT
// 2. Flutter/React → envia JWT no header Authorization: Bearer <token>
// 3. NestJS guard → valida JWT com Supabase Admin SDK
// 4. Injeta user no request com role e id
```

---

## 9. Fluxo de Eventos: Fase Validada

Quando cliente aprova uma fase, a cadeia dispara automaticamente:

```
FaseValidada
    ├──► LiberarPagamento (Stripe transfer)
    ├──► NotificarTrabalhador (FCM)
    ├──► NotificarCliente (FCM)
    ├──► AtualizarReputação (worker score)
    └──► PreverProximaFase (Materials Hub — Fase 2)
```

Implementação: **BullMQ + Redis** com retry automático e dead letter queue.

---

## 10. Materials Hub — Fluxo (Fase 2)

1. Projeto ativado → sistema gera lista de materiais por fase
2. Matching automático com fornecedores disponíveis
3. OX valida: preço + prazo + localização + rating
4. Pedido confirmado com slot de entrega
5. Tracking em tempo real
6. **Replacement Engine:** se fornecedor A vai atrasar → sistema propõe B ou C automaticamente
7. Worker confirma recebimento na obra com foto
8. Sistema atualiza progresso do projeto

**Não é um marketplace aberto — OX controla toda a cadeia.**

---

## 11. Infraestrutura Docker

### Containers em desenvolvimento

| Container | Função |
|---|---|
| `ox-api` | NestJS API (hot reload) |
| `ox-worker` | BullMQ consumer separado |
| `postgres` | Banco local |
| `redis` | Cache + filas |
| `ox-migrate` | Prisma migrate (roda e sai) |
| `stripe-cli` | Webhooks locais (profile: stripe) |
| `pgadmin` | UI visual do banco (profile: tools) |
| `redis-commander` | UI visual do Redis (profile: tools) |

### Comando para subir tudo

```bash
cp .env.example .env
make dev
# API:    http://localhost:3000
# Docs:   http://localhost:3000/api/docs
# Health: http://localhost:3000/health
```

### Deploy produção

- **Railway:** backend (ox-api + ox-worker + Redis + Postgres plugins)
- **Vercel:** React admin (deploy automático via GitHub)
- **Supabase:** Auth + Storage + Realtime (externo ao Railway)
- **GitHub Actions:** CI/CD — push main → testes → build Docker → deploy

---

## 12. Apps Flutter

### App Cliente — Telas MVP

1. Login / Registro (via Supabase Auth)
2. Lista de projetos
3. Criar projeto (formulário + upload fotos)
4. Detalhe do projeto (fases + status)
5. Validação de fase (ver fotos do worker, aprovar/rejeitar)
6. Status do escrow / pagamento

### App Trabalhador — Telas MVP

1. Login (via Supabase Auth)
2. Dashboard de jobs disponíveis
3. Detalhe de job (aceitar/recusar)
4. Execução de fase + upload fotos/vídeo
5. Checklist da fase
6. Histórico de pagamentos

### Dependências Flutter

```yaml
dio              # HTTP client com interceptors
go_router        # navegação
riverpod         # state management
image_picker     # upload de fotos
firebase_core    # push notifications
firebase_messaging
shared_preferences
intl             # datas e moedas
```

---

## 13. React Admin Panel

### Páginas MVP

1. `/login` — auth admin
2. `/projects` — lista com filtro por status
3. `/projects/[id]` — detalhe + mudar status manualmente
4. `/workers` — lista + ratings
5. `/payments` — relatório financeiro
6. `/matching/[projectId]` — atribuir worker manualmente

### Stack

```
Next.js + TypeScript + Tailwind
Axios + React Query
Recharts (gráficos)
Lucide React (ícones)
```

---

## 14. Roadmap de Desenvolvimento

| Sprint | Semanas | Entrega |
|---|---|---|
| 1 | 1–2 | Auth (Supabase) + estrutura NestJS + ERD |
| 2 | 3–4 | CRUD projetos + upload evidências + state machine |
| 3 | 5–6 | Matching manual + contratos |
| 4 | 7–8 | **Stripe Connect + escrow (POC financeiro)** |
| 5 | 9–10 | Fases + validação + liberação automática |
| 6 | 11–12 | Flutter app cliente |
| 7 | 13–14 | Flutter app trabalhador |
| 8 | 15–16 | React admin + notificações + deploy |
| Fase 2 | Pós-MVP | Materials Hub + matching IA + Replacement Engine |

**Regra de ouro:** teste o Stripe Connect ANTES de qualquer tela bonita.

---

## 15. Os 5 Erros Fatais a Evitar

1. Microservices desde o início
2. Começar pelo frontend bonito antes do escrow funcionar
3. Não definir state machine explícita
4. Construir chat próprio (usar Stream Chat)
5. Tentar lançar tudo junto (Materials Hub é Fase 2)

---

## 16. Ferramentas de Apoio

| Categoria | Ferramenta |
|---|---|
| Modelagem ERD | dbdiagram.io |
| Wireframes | Figma |
| API testing | Bruno / Insomnia |
| Documentação API | Swagger / OpenAPI |
| Prisma UI | Prisma Studio (`npx prisma studio`) |
| CI/CD | GitHub Actions |
| Deploy backend | Railway |
| Deploy admin | Vercel |
| Monitoramento | Sentry + Logtail + UptimeRobot |
| Webhooks locais | Stripe CLI |

---

## 17. Arquivos Gerados Nesta Sessão

| Arquivo | Conteúdo |
|---|---|
| `ox-arquitetura-tecnica.md` | Arquitetura consolidada (referência principal) |
| `ox-arquitetura-diagramas.html` | 7 diagramas Mermaid da arquitetura |
| `ox-diagramas-adicionais.html` | Materials Hub + Deploy + CI/CD |
| `ox-passo-a-passo.md` | Guia de desenvolvimento Fase 0 a 15 |
| `ox-docker-guide.md` | Dockerfiles, Compose, scripts, CI/CD |
| `ox-contexto-completo.md` | Este arquivo |

---

## 18. Decisões Técnicas Registradas

| Decisão | Escolha | Motivo |
|---|---|---|
| Arquitetura | Modular Monolith | Solo dev — microservices mata produtividade |
| Auth | Supabase Auth | Já implementado — não reinventar |
| Backend | NestJS + TypeScript | DDD nativo, modular, enterprise |
| Banco | PostgreSQL via Supabase | ACID obrigatório para escrow |
| State Machine | XState | Battle-tested, auditável, visualizável |
| Filas | BullMQ + Redis | Retry automático, dead letter queue |
| Pagamentos | Stripe Connect | Split automático nativo |
| Storage | Supabase Storage | Integrado ao ecossistema já em uso |
| Chat | Stream Chat (se precisar) | Não construir do zero |
| Deploy | Railway + Vercel | Custo mínimo, zero DevOps pesado |
| CI/CD | GitHub Actions | Integrado ao repositório |
| Containers | Docker + Compose | Dev local + produção consistentes |

---

## 19. Comparação de Ferramentas de Desenvolvimento (Avaliadas)

| Ferramenta | Adequação para OX |
|---|---|
| **Claude Code** | ✅ Acessa código real, roda comandos, edita arquivos |
| **GPT-5.5 + Roo Code** | ✅ VS Code integrado, suporta modelos OpenAI |
| **DeepSeek V4 Pro** | ✅ 1M tokens, grátis no chat, sem multimodal |
| **Claude.ai (esta sessão)** | ✅ Planejamento, arquitetura, documentação |

**Recomendação:** Use Claude.ai ou DeepSeek V4 para planejamento. Use Claude Code ou Roo Code para desenvolvimento ativo no código.

---

## 20. Frase de Posicionamento (Pitch)

> *"Não estamos construindo um app de reformas. Estamos construindo um sistema operacional da construção — onde execução, supply chain e pagamento estão completamente sincronizados em uma única plataforma controlada."*

---

## Como Usar Este Arquivo

Cole este documento como contexto inicial ao iniciar uma nova sessão em qualquer ferramenta:

**Claude Code:**
```
Tenho um projeto chamado OX Field Service. Aqui está todo o contexto
da arquitetura e decisões técnicas: [colar este arquivo]
Quero continuar o desenvolvimento a partir de onde parei.
```

**Roo Code (VS Code):**
```
Contexto do projeto OX Field Service: [colar este arquivo]
Já tenho autenticação com Supabase implementada.
Próximo passo: [descrever o que quer fazer]
```

**DeepSeek V4 / GPT-5.5:**
```
Preciso de ajuda com o projeto OX Field Service.
Contexto completo: [colar este arquivo]
Pergunta específica: [sua dúvida]
```

---

*Gerado em sessão de planejamento — OX Field Service · Solo Dev · Vibe Coding*
*Autenticação: Supabase Auth (implementado) · Próximo: Schema Prisma + Módulo de Projetos*
