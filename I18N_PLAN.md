# Plano de Internacionalização (i18n)

**Idiomas alvo:** Inglês (EN) · Holandês (NL) · Espanhol (ES) · Português (PT)  
**Apps:** ox-app-client · ox-app-worker · ox-admin

---

## Fase 1 — ox-app-client (Flutter)

**Pré-requisito:** Estrutura ARB já existe com EN, NL e PT (~75 keys)  
**Esforço estimado:** 2–4h

### Tarefas

- [ ] Criar `lib/l10n/app_es.arb` com todas as traduções para Espanhol
- [ ] Manter `app_pt.arb` e garantir que está completo e atualizado
- [ ] Atualizar `l10n.yaml` para incluir EN, NL, ES e PT nos locales suportados
- [ ] Rodar `flutter gen-l10n` para gerar o código
- [ ] Criar widget `LanguageSelectorWidget` (dropdown ou bottom sheet)
- [ ] Persistir idioma escolhido em `SharedPreferences`
- [ ] Aplicar locale persistido no `MaterialApp` via provider/controller
- [ ] Adicionar seletor de idioma na tela de Perfil e/ou Settings
- [ ] Testar nas 3 línguas: telas de auth, onboarding, projetos, pagamentos, notificações

### Arquivos-chave
- `lib/l10n/` — arquivos ARB
- `lib/main.dart` — configuração do MaterialApp e locales
- `lib/features/profile/` — onde o seletor vai aparecer

### Critério de conclusão
App compila, troca de idioma persiste entre sessões, todas as telas traduzidas.

---

## Fase 2 — ox-app-worker (Flutter)

**Pré-requisito:** Pacote `intl` já está no `pubspec.yaml`, sem ARB files  
**Esforço estimado:** 4–8h

### Tarefas

- [ ] Adicionar `flutter_localizations` e `intl` no `pubspec.yaml` (se não estiver)
- [ ] Criar `l10n.yaml` copiando configuração do ox-app-client
- [ ] Auditar todos os 44 arquivos Dart e extrair strings hardcoded
- [ ] Criar `lib/l10n/app_en.arb` com todas as keys extraídas
- [ ] Criar `lib/l10n/app_nl.arb` — Holandês
- [ ] Criar `lib/l10n/app_es.arb` — Espanhol
- [ ] Criar `lib/l10n/app_pt.arb` — Português
- [ ] Rodar `flutter gen-l10n`
- [ ] Substituir strings hardcoded nos arquivos pelos `AppLocalizations.of(context).key`
- [ ] Copiar `LanguageSelectorWidget` do ox-app-client (reusar)
- [ ] Persistir e aplicar locale no `MaterialApp`
- [ ] Adicionar seletor na tela de Perfil e/ou Settings
- [ ] Testar nas 3 línguas: auth, onboarding, jobs, execução, pagamentos, notificações

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

## Strings a não esquecer

Categorias que costumam ter strings fora dos componentes principais:

- Mensagens de validação de formulário
- Textos de estados vazios ("Nenhum resultado encontrado")
- Labels de status (ex: "Pendente", "Em andamento", "Concluído")
- Mensagens de erro de rede/API
- Textos de confirmação em modais/dialogs
- Notificações push (títulos e bodies)

---

## Notas de tradução

- Strings em Holandês (NL) e Português (PT) já existem no ox-app-client — reutilizar como referência
- Para ES e NL nas partes novas: gerar com LLM e revisar manualmente antes de produção
- PT é idioma nativo do projeto — priorizar revisão das traduções PT em novos conteúdos
- Evitar traduções automáticas para termos técnicos do domínio (ex: "escrow", "fase", nomes de status)
