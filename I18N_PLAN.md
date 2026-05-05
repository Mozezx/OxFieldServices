# Plano de Internacionalização (i18n)

**Idiomas alvo:** Inglês (EN) · Holandês (NL) · Espanhol (ES) · Português (PT)  
**Apps:** ox-app-client · ox-app-worker · ox-admin

---

## Fase 1 — ox-app-client (Flutter) ✅ CONCLUÍDA

**Pré-requisito:** Estrutura ARB já existe com EN, NL e PT (~75 keys)  
**Esforço estimado:** 2–4h

### Tarefas

- [x] Criar `lib/l10n/app_es.arb` com todas as traduções para Espanhol
- [x] Manter `app_pt.arb` e garantir que está completo e atualizado (~160 keys)
- [x] Atualizar `l10n.yaml` para incluir EN, NL, ES e PT nos locales suportados
- [x] Rodar `flutter gen-l10n` para gerar o código
- [x] Criar widget `LanguageSelectorWidget` (bottom sheet com 4 idiomas)
- [x] Persistir idioma escolhido em `SharedPreferences`
- [x] Aplicar locale persistido no `MaterialApp` via `localeProvider` (Riverpod)
- [x] Adicionar seletor de idioma na tela de Perfil
- [x] Migrar todas as telas para usar `AppLocalizations.of(context)!` — auth, onboarding, projetos, notificações, fases, perfil
- [x] Traduzir labels da barra de navegação inferior (`navProjects`, `navNotifications`, `navProfile`)
- [x] Traduzir strings do canal de notificações push Android (`pushChannelName`, `pushChannelDescription`)

### Arquivos-chave
- `lib/l10n/` — arquivos ARB (PT = template com `@key` metadata)
- `lib/core/l10n/locale_provider.dart` — `StateNotifierProvider<LocaleNotifier, Locale>`
- `lib/core/l10n/language_selector_widget.dart` — seletor de idioma reutilizável
- `lib/core/router/main_shell.dart` — barra de navegação inferior (usa `AppLocalizations`)
- `lib/core/notifications/push_notifications_service.dart` — recebe strings de canal via parâmetros
- `lib/app.dart` — usa `lookupAppLocalizations(locale)` para passar strings ao serviço de push

### Critério de conclusão
✅ App compila sem erros, troca de idioma persiste entre sessões, todas as telas traduzidas, `flutter analyze` retorna zero erros.

---

## Fase 2 — ox-app-worker (Flutter) ✅ CONCLUÍDA

**Pré-requisito:** Pacote `intl` já está no `pubspec.yaml`, sem ARB files  
**Esforço estimado:** 4–8h

### Tarefas

- [x] Adicionar `flutter_localizations` e `intl` no `pubspec.yaml` (se não estiver)
- [x] Criar `l10n.yaml` copiando configuração do ox-app-client
- [x] Auditar todos os 44 arquivos Dart e extrair strings hardcoded
- [x] Criar `lib/l10n/app_en.arb` com todas as keys extraídas
- [x] Criar `lib/l10n/app_nl.arb` — Holandês
- [x] Criar `lib/l10n/app_es.arb` — Espanhol
- [x] Criar `lib/l10n/app_pt.arb` — Português
- [x] Rodar `flutter gen-l10n`
- [x] Substituir strings hardcoded nos arquivos pelos `AppLocalizations.of(context).key`
- [x] Copiar `LanguageSelectorWidget` do ox-app-client (reusar)
- [x] Persistir e aplicar locale no `MaterialApp`
- [x] Adicionar seletor na tela de Perfil e/ou Settings
- [x] Testar nas 3 línguas: auth, onboarding, jobs, execução, pagamentos, notificações (`flutter analyze` sem issues)

### Arquivos-chave
- `lib/l10n/` — criar do zero
- `lib/main.dart` — configurar locales
- `lib/features/` — substituir strings em todos os features

### Critério de conclusão
Mesmo critério da Fase 1. Sem strings hardcoded em português/inglês visíveis na UI.

---

## Fase 3 — ox-admin (Next.js 14)

**Pré-requisito:** Nenhum — setup completo do zero  
**Esforço estimado:** 8–12h

### Tarefas

#### Setup
- [ ] Instalar `next-intl`
- [ ] Criar `next.config.js` com plugin do next-intl
- [ ] Criar `src/i18n.ts` e `src/middleware.ts` para roteamento por locale
- [ ] Definir estrutura de rotas: `/en/...`, `/nl/...`, `/es/...`

#### Arquivos de tradução
- [ ] Criar `messages/en.json` — Inglês (fonte principal)
- [ ] Criar `messages/nl.json` — Holandês
- [ ] Criar `messages/es.json` — Espanhol
- [ ] Criar `messages/pt.json` — Português
- [ ] Auditar os ~33 componentes/páginas e extrair todas as strings

#### Componentes
- [ ] Criar componente `LanguageSwitcher` para o Header
- [ ] Integrar no `Header.tsx` existente
- [ ] Persistir preferência de idioma em cookie (para SSR funcionar)

#### Migração de strings
- [ ] `app/(auth)/` — páginas de login/auth
- [ ] `app/(dashboard)/` — todas as páginas do painel admin
- [ ] `components/layout/` — Header, Sidebar, navegação
- [ ] `components/ui/` — labels, placeholders, mensagens de erro
- [ ] Mensagens de feedback (toasts, alertas, confirmações)

#### Testes
- [ ] Navegar por todas as rotas nos 3 idiomas
- [ ] Verificar que SSR renderiza no idioma correto
- [ ] Verificar persistência de idioma ao recarregar página

### Arquivos-chave
- `messages/` — criar do zero
- `middleware.ts` — já existe, adicionar lógica de locale
- `components/layout/Header.tsx` — adicionar LanguageSwitcher

### Critério de conclusão
Admin funciona em EN/NL/ES, idioma persiste via cookie, sem strings hardcoded visíveis.

---

## Dependências entre fases

```
Fase 1 (client) → valida padrão ARB + seletor de idioma
      ↓
Fase 2 (worker) → reutiliza tudo da Fase 1
      ↓
Fase 3 (admin)  → stack diferente, independente
```

Fases 1 e 2 podem ser feitas em sequência rápida. Fase 3 é independente e pode rodar em paralelo se houver dois contextos de trabalho.

---

## Padrão: Histórico de notificações traduzível (type + metadata)

**Problema:** notificações são gravadas no banco com texto em português fixo. Mudar o idioma no app não traduzia o histórico.

**Solução implementada no ox-app-client:**

O backend grava um campo `data` (JSON) em cada notificação com as variáveis do template e um campo `variant` que diferencia mensagens para destinatários diferentes:

```json
{
  "type": "phase_validated",
  "title": "Fase validada",
  "body": "A fase Pintura do projeto Casa Verde foi validada.",
  "data": {
    "projectId": "...",
    "phaseName": "Pintura",
    "projectTitle": "Casa Verde",
    "variant": "client"
  }
}
```

O cliente Flutter lê `type` + `data` e monta o texto traduzido na hora via `AppLocalizations`. Se o tipo for desconhecido, cai no `title`/`body` gravado como fallback.

**Arquivo de referência:** `lib/features/notifications/notifications_screen.dart` — funções `_resolveTitle()` e `_resolveBody()`.

**Para replicar este padrão nas fases 2 e 3:**
- Backend: ao criar uma notificação, popular o campo `data` com `{ variant, ...templateVars }` além dos campos relacionais já existentes
- Frontend: mapear cada `type` para as chaves ARB equivalentes em `_resolveTitle` e `_resolveBody`; manter `title`/`body` como fallback para retrocompatibilidade
- ARB: criar pares `notifXxxTitle` / `notifXxxBody` para cada tipo; usar sufixo `Client`, `Worker`, `Admin` quando o mesmo tipo tem mensagens distintas por destinatário

---

## Strings a não esquecer

Categorias que costumam ter strings fora dos componentes principais:

- **Barra de navegação inferior** — labels de `BottomNavigationBarItem` ficam fora das telas; usar `navProjects / navNotifications / navProfile` via `AppLocalizations`
- **Canal de notificações push (Android)** — `AndroidNotificationChannel` name/description não têm `BuildContext`; passar como parâmetros usando `lookupAppLocalizations(locale)` no ponto de inicialização (padrão já aplicado em `push_notifications_service.dart`)
- **Histórico de notificações** — conteúdo vem do banco, não do código Flutter; usar padrão type+metadata descrito acima
- Mensagens de validação de formulário
- Textos de estados vazios ("Nenhum resultado encontrado")
- Labels de status (ex: "Pendente", "Em andamento", "Concluído")
- Mensagens de erro de rede/API
- Textos de confirmação em modais/dialogs

---

## Notas de tradução

- Strings em Holandês (NL) e Português (PT) já existem no ox-app-client — reutilizar como referência
- Para ES e NL nas partes novas: gerar com LLM e revisar manualmente antes de produção
- PT é idioma nativo do projeto — priorizar revisão das traduções PT em novos conteúdos
- Evitar traduções automáticas para termos técnicos do domínio (ex: "escrow", "fase", nomes de status)
