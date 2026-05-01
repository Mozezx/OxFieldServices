# Master Plan Detalhado — OX Field Service

## 1. Objetivo mestre

Construir o MVP operacional do OX Field Service como um **sistema transacional auditável** onde:
- o cliente cria e financia um projeto,
- a OX valida e atribui execução,
- o worker executa por fases,
- cada fase exige evidência,
- o pagamento só é liberado após validação,
- toda a operação é rastreável.

A base arquitetural continua sendo o monólito modular descrito em `ox-contexto-completo.md` e parcialmente implementado em `ox-backend/src/app.module.ts`.

---

## 2. Resultado final esperado do MVP

Ao final do master plan, o sistema deve permitir este fluxo end-to-end:

1. usuário autentica via Supabase
2. perfil local é sincronizado
3. cliente cria projeto com fases
4. OX/admin valida projeto
5. worker é atribuído
6. contrato é criado
7. cliente deposita valor em escrow
8. projeto entra em execução
9. worker envia evidências por fase
10. cliente aprova ou rejeita fases
11. ao validar as fases, o sistema libera pagamento corretamente
12. notificações e trilha de auditoria registram tudo
13. admin acompanha operação e finanças

Esse é o “MVP real”, não apenas CRUD. O centro do plano é transformar documentação em runtime confiável.

---

## 3. Princípios de execução

### 3.1 O que nunca pode ser violado
- pagamento nunca sai do frontend
- fase nunca é validada sem evidência
- transição de estado nunca ocorre sem regra explícita
- webhook nunca é processado sem assinatura válida
- operação financeira nunca roda sem idempotência
- autorização nunca depende só da UI
- Materials Hub não entra antes do MVP financeiro fechar
- interfaces web e mobile devem nascer preparadas para i18n com suporte mínimo a português, inglês e holandês

### 3.2 Ordem de prioridade
1. segurança de acesso
2. integridade de estado
3. integridade financeira
4. rastreabilidade operacional
5. internacionalização das interfaces
6. experiência de uso
7. automações auxiliares

### 3.3 Definição real de pronto
Uma fase só está pronta quando houver:
- implementação
- validação técnica
- testes mínimos
- documentação curta atualizada
- critérios de aceite satisfeitos

---

## 4. Estratégia macro de entrega

O plano será executado em **8 macro-blocos**, cada um com objetivo, entregáveis, riscos e critério de saída.

1. Foundation Hardening
2. Evidence Flow
3. Contract + Matching MVP
4. Escrow + Stripe POC real
5. Phase Validation + Payment Release
6. Notifications + Auditability
7. Admin + Client + Worker Apps
8. Production Readiness

---

## 5. Bloco 1 — Foundation Hardening

### Objetivo
Transformar a base atual do backend em uma fundação segura, coerente e pronta para suportar fluxo financeiro.

### Estado atual relacionado
- auth existe em `ox-backend/src/modules/auth/auth.controller.ts`
- projects existe em `ox-backend/src/modules/projects/projects.service.ts`
- phases existe em `ox-backend/src/modules/phases/phases.service.ts`
- state machine de projeto existe em `ox-backend/src/common/state-machine/project.machine.ts`

### Entregáveis
#### 5.1 Congelar decisões técnicas
Definir oficialmente e documentar sem ambiguidade:
- banco principal de produção: Supabase Postgres
- filas: Bull ou BullMQ, escolher um só
- gateway de pagamento MVP: Stripe Connect apenas
- realtime MVP: opcional, não bloqueante
- admin: Next.js/Tailwind conforme visão já documentada

#### 5.2 Endurecer autenticação e perfil
- corrigir validação de role em `ox-backend/src/modules/auth/dto/sync-profile.dto.ts`
- padronizar retorno de `ox-backend/src/modules/auth/auth.controller.ts`
- garantir que profile sync não permita role arbitrária fora do escopo MVP
- adicionar testes para sync e auth guard

#### 5.3 Endurecer autorização
Implementar policy real para acesso:
- client vê apenas seus projetos
- worker vê apenas projetos atribuídos a ele
- admin vê tudo
- client vê apenas fases do próprio projeto
- worker vê apenas fases do projeto ao qual está vinculado

#### 5.4 Fortalecer state control
- criar state machine explícita de fase, equivalente à de projeto
- remover lógica de transição espalhada no service
- centralizar eventos permitidos por papel

#### 5.5 Higiene técnica
- exceptions padronizadas
- logs estruturados mínimos
- DTOs mais estritos
- normalização de respostas
- testes unitários para serviços core

### Critério de saída do bloco 1
O backend deve estar consistente em autenticação, autorização e transições antes de tocar o fluxo financeiro.

---

## 6. Bloco 2 — Evidence Flow

### Objetivo
Fechar o primeiro diferencial operacional do produto: evidência obrigatória por fase.

### Entregáveis
#### 6.1 Storage real
Implementar serviço de evidências com Supabase Storage conforme previsto em `ox-passo-a-passo.md`, mas em código de produção.

Deve incluir:
- bucket dedicado
- convenção de path por projeto/fase
- metadata mínima
- política de acesso segura
- persistência em `ox-backend/prisma/schema.prisma`

#### 6.2 Endpoint de upload
Criar endpoint autenticado para upload de evidência com:
- validação de mime type
- limite de tamanho
- suporte inicial a imagem
- opcionalmente vídeo no segundo passo
- vínculo com fase
- vínculo com usuário uploader

#### 6.3 Regras de fase
Fluxo mínimo:
- `pending` → `in_progress`
- `in_progress` → `evidence_uploaded`
- `evidence_uploaded` → `under_review`
- `under_review` → `validated | rejected`
- `rejected` → `in_progress`

#### 6.4 Regra inviolável
Implementar enforcement duro:
- se não existir evidência, não pode validar
- se a evidência não pertence à fase, não conta
- se a fase não está em `under_review`, não pode aprovar/rejeitar

#### 6.5 UX operacional mínima para evidência
Backend precisa retornar:
- lista de evidências da fase
- tipo
- URL
- timestamp
- uploader

### Critério de saída do bloco 2
O sistema deve permitir execução real de fase com prova auditável.

---

## 7. Bloco 3 — Contract + Matching MVP

### Objetivo
Fechar a ligação entre projeto validado e worker responsável.

### Entregáveis
#### 7.1 Módulo de workers
Implementar perfil de worker com dados essenciais:
- certificação Shelter
- skills
- disponibilidade
- rating
- identificação de conta de pagamento futura

#### 7.2 Matching MVP manual-assistido
Sem IA.

Fluxo:
- admin consulta candidatos elegíveis
- sistema sugere por critérios simples
- admin confirma atribuição

Critérios:
- disponível
- certificado
- rating mínimo
- skill compatível se existir

#### 7.3 Contrato digital MVP
Criar módulo de contratos com:
- geração de contrato no banco
- snapshot financeiro do projeto
- vínculo projeto-worker
- status de assinatura
- timestamp de aceite

#### 7.4 Regras de integridade
- projeto só pode ser atribuído uma vez
- contrato só pode existir para projeto elegível
- worker só pode aceitar projeto se estiver disponível
- mudança para `contract_signed` só ocorre com contrato válido

### Critério de saída do bloco 3
Todo projeto elegível deve conseguir sair de validação para uma execução contratada.

---

## 8. Bloco 4 — Escrow + Stripe POC real

### Objetivo
Implementar o coração econômico do produto com segurança real.

### Entregáveis
#### 8.1 Modelo de pagamento operacional
Conectar as entidades já existentes no Prisma:
- `Contract`
- `EscrowTxn`
- `Payment`

#### 8.2 Serviço Stripe
Implementar serviço dedicado para:
- criação de connected account do worker
- criação de payment intent / reserve / capture conforme modelo escolhido
- webhook handling
- transferências com idempotência

#### 8.3 Definir modelo financeiro exato do MVP
Antes de codar, congelar um modelo único:
- escrow total no início do projeto, ou
- captura por fase, ou
- autorização inicial + release parcial por milestones

Recomendação MVP:
- depósito/garantia no início
- liberação por evento validado
- split simples inicialmente: worker + plataforma
- fornecedor fora do fluxo MVP financeiro inicial

#### 8.4 Webhook seguro
Implementar rota de webhook com:
- raw body
- verificação de assinatura
- idempotência por evento Stripe
- persistência de logs do evento
- tolerância a retry

#### 8.5 Reconciliação mínima
Cada evento Stripe relevante precisa produzir estado local consistente:
- intent criado
- escrow confirmado
- transferência criada
- transferência concluída
- falha/retry

### Critério de saída do bloco 4
O sistema deve conseguir simular dinheiro bloqueado e posterior liberação com segurança técnica real.

---

## 9. Bloco 5 — Phase Validation + Payment Release

### Objetivo
Conectar execução, validação e dinheiro.

### Entregáveis
#### 9.1 Fluxo formal de aprovação
Quando o cliente aprova uma fase:
- validar ownership
- validar presença de evidências
- validar estado da fase
- persistir mudança de status
- disparar processo assíncrono ou síncrono controlado

#### 9.2 Política de liberação financeira
Congelar regra de negócio:
- liberar por fase individual, ou
- liberar apenas ao fim de todas as fases

Recomendação de produto:
- liberar por fase validada, porque reforça incentivo operacional e reduz atrito.

#### 9.3 Payment release service
Implementar serviço que:
- calcula valor liberável
- impede duplicidade
- gera registros em `Payment`
- interage com Stripe
- atualiza `EscrowTxn` de modo transacional

#### 9.4 Fechamento do projeto
Quando todas as fases estiverem validadas:
- avançar projeto para `closing`
- confirmar encerramento
- consolidar pagamentos
- registrar indicadores finais

### Critério de saída do bloco 5
O principal loop do negócio deve funcionar ponta a ponta.

---

## 10. Bloco 6 — Notifications + Auditability

### Objetivo
Tornar a operação observável, notificável e confiável.

### Entregáveis
#### 10.1 Camada de eventos
Escolher e implementar definitivamente:
- Bull + Redis, ou
- BullMQ + Redis

Use uma única stack.

#### 10.2 Eventos de domínio mínimos
Criar eventos para:
- profile synced
- project submitted
- project approved
- worker assigned
- contract signed
- escrow funded
- phase evidence uploaded
- phase submitted for review
- phase validated
- payment released
- project closed

#### 10.3 Notificações push
Implementar módulo de notificações para eventos de alto valor:
- fase enviada para revisão
- fase aprovada
- fase rejeitada
- pagamento liberado
- ação pendente para cliente
- ação pendente para worker

#### 10.4 Auditoria operacional
Criar trilha mínima de auditoria com:
- ator
- ação
- entidade
- payload mínimo
- timestamp
- correlation id

#### 10.5 Observabilidade
Integrar:
- Sentry
- logs estruturados
- health endpoints
- alertas básicos

### Critério de saída do bloco 6
Toda ação crítica deve ser rastreável e os atores devem ser notificados no momento certo.

---

## 11. Bloco 7 — Produtos cliente

### Objetivo
Entregar interfaces mínimas que usem o backend já estabilizado.

### Diretriz transversal de idioma
Todas as interfaces do MVP devem ser preparadas desde o início para internacionalização.

Idiomas obrigatórios:
- português
- inglês
- holandês

Regras:
- não hardcodar textos diretamente em componentes
- centralizar strings por domínio e por tela
- suportar troca de idioma no app e no painel web
- formatar datas, moeda e números conforme locale
- priorizar tradução de toda jornada crítica do MVP antes de textos secundários
- manter chaves estáveis para facilitar evolução futura

### Sub-bloco 7A — App Cliente
Fluxo mínimo:
- login
- sync profile
- lista de projetos
- criar projeto
- ver fases
- ver evidências
- aprovar/rejeitar fase
- ver status do escrow/pagamento

Entregas adicionais de i18n:
- textos de autenticação em 3 idiomas
- labels de projeto, fase, evidência e pagamento em 3 idiomas
- mensagens de erro e estados vazios traduzidos

### Sub-bloco 7B — App Worker
Fluxo mínimo:
- login
- ver jobs atribuídos
- aceitar fluxo operacional
- iniciar fase
- subir evidência
- reenviar após rejeição
- ver pagamentos

Entregas adicionais de i18n:
- status operacionais traduzidos
- instruções de upload e validação traduzidas
- mensagens de aprovação, rejeição e pagamento traduzidas

### Sub-bloco 7C — Admin Web
Fluxo mínimo:
- login admin
- validar projeto
- ver candidatos
- atribuir worker
- acompanhar status dos projetos
- acompanhar pagamentos
- visão operacional por status

Entregas adicionais de i18n:
- filtros, tabelas, badges e dashboards em 3 idiomas
- mensagens operacionais e confirmações traduzidas
- estrutura preparada para expansão futura de novos idiomas sem refatoração ampla

### Estratégia de desenvolvimento
Não construir tudo em paralelo.

Ordem recomendada:
1. admin web
2. app cliente
3. app worker

Motivo: o admin fecha operação e debugging mais rápido.

### Critérios técnicos de i18n
- web admin com biblioteca de i18n compatível com o framework usado em [`ox-admin`](ox-admin)
- apps Flutter com estratégia de localização nativa e arquivos de tradução versionados
- backend retornando códigos de status e mensagens que não travem a tradução no frontend
- nomenclatura de estados internos desacoplada do texto exibido ao usuário

### Critério de saída do bloco 7
Todos os atores do MVP conseguem completar suas ações essenciais sem operação manual fora do sistema.

---

## 12. Bloco 8 — Production Readiness

### Objetivo
Preparar o sistema para uso real controlado.

### Entregáveis
#### 12.1 Infra oficial
Congelar stack de produção:
- backend: Railway
- DB/Auth/Storage: Supabase
- admin: Vercel
- Redis: Railway ou provedor dedicado

#### 12.2 Segurança operacional
- CORS de produção
- rate limit
- secrets management
- buckets seguros
- RLS no que fizer sentido no Supabase
- proteção de webhook
- backups e restore testados

#### 12.3 CI/CD
Pipeline mínimo:
- lint
- test
- build
- migration controlada
- deploy staging
- deploy produção

#### 12.4 Testes de smoke do fluxo crítico
Checklist obrigatório de produção:
- login
- sync de perfil
- criação de projeto
- aprovação de projeto
- contrato
- funding do escrow
- upload de evidência
- validação de fase
- liberação de pagamento
- encerramento

#### 12.5 Beta controlado
Lançar primeiro com operação assistida:
- poucos clientes
- poucos workers
- poucos projetos reais
- monitoramento manual de cada caso

### Critério de saída do bloco 8
Sistema apto para beta real com risco controlado.

---

## 13. Backlog executivo priorizado

## Prioridade P0 — obrigatória antes do financeiro
- corrigir validações de auth/profile
- autorização fina em projetos e fases
- state machine de fase
- upload real de evidências
- regra “sem evidência = sem validação”
- testes mínimos desses fluxos

## Prioridade P1 — núcleo do MVP
- workers
- matching manual
- contratos
- Stripe Connect real
- webhook seguro
- escrow funcional
- liberação de pagamento

## Prioridade P2 — operação assistida
- notificações
- auditoria
- admin panel
- dashboards básicos

## Prioridade P3 — experiência expandida
- app cliente refinado
- app worker refinado
- realtime de status
- relatórios melhores

## Prioridade P4 — pós-MVP
- Materials Hub
- fornecedores
- replacement engine
- supply chain automatizado
- Mollie se realmente necessário
- chat, apenas se validar necessidade

---

## 14. Sequência tática recomendada de implementação

### Sprint 1 — Hardening backend core
- auth e role fixes
- access control real
- phase state machine
- testes base

### Sprint 2 — Evidence flow completo
- upload endpoint
- Supabase Storage
- evidência por fase
- review flow

### Sprint 3 — Workers + matching + contratos
- worker profile
- candidate selection
- contract creation
- transição até `contract_signed`

### Sprint 4 — Stripe escrow POC
- connected account
- funding flow
- webhook
- persistência financeira

### Sprint 5 — Validation to payment
- validar fase com regra dura
- release financeiro
- fechamento do projeto
- auditoria mínima

### Sprint 6 — Admin operacional
- telas admin essenciais
- painel de projetos
- painel de matching
- painel financeiro

### Sprint 7 — Cliente e worker apps
- cliente: criação + aprovação
- worker: execução + upload + pagamentos

### Sprint 8 — Produção e beta controlado
- deploy
- monitoramento
- smoke tests
- rollout assistido

---

## 15. Critérios de aceite por domínio

### Auth
- usuário com JWT válido acessa rotas autorizadas
- usuário sem perfil local recebe fluxo claro de sync
- role inválida não entra

### Projects
- client cria e edita apenas o seu projeto
- transições inválidas falham
- transições válidas respeitam papel

### Phases
- worker só move fase permitida
- cliente só aprova fase revisável
- fase sem evidência nunca valida

### Contracts
- um projeto elegível gera um contrato único
- worker atribuído fica vinculado corretamente

### Payments
- escrow é registrado localmente
- webhook altera estado com segurança
- pagamento não duplica
- liberação deixa trilha auditável

### Notifications
- eventos críticos notificam atores corretos
- falha de push não quebra fluxo central

---

## 16. Riscos que o plano precisa controlar

### Risco 1 — documentação mais madura que código
Mitigação: cada bloco fecha software executável antes do próximo.

### Risco 2 — desvio para features pós-MVP
Mitigação: Materials Hub bloqueado até beta do fluxo financeiro.

### Risco 3 — falha de autorização
Mitigação: policies explícitas e testes por papel.

### Risco 4 — falha financeira
Mitigação: Stripe test mode, webhook seguro, idempotência, reconciliação.

### Risco 5 — excesso de frentes paralelas
Mitigação: backend primeiro, depois admin, depois apps.

---

## 17. Definição de sucesso do projeto

O projeto será considerado bem-sucedido quando:
- o backend suportar o fluxo crítico completo,
- o dinheiro só for liberado após validação legítima,
- o sistema for auditável,
- o admin conseguir operar sem gambiarras externas,
- cliente e worker conseguirem completar suas jornadas mínimas,
- o beta real rodar com poucos casos e sem quebra de integridade.

---

## 18. Mandato final do master plan

A execução do OX deve seguir esta regra simples:

**primeiro garantir integridade operacional e financeira, depois acelerar interface, escala e expansão.**

Isso preserva exatamente o diferencial do produto descrito em `ox-contexto-completo.md`, sem transformar o projeto em mais um CRUD bonito sem mecanismo real de confiança.
