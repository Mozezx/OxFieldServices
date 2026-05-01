# OX Field Service — Passo a Passo do Zero

> Guia prático e sequencial para um dev solo iniciar o desenvolvimento do ecossistema OX com vibe coding.
> Siga cada etapa em ordem. Não pule fases.

---

## Sumário

- ✅ [Fase 0 — Preparação do Ambiente](#fase-0--preparação-do-ambiente)
- ✅ [Fase 1 — Modelagem e Design](#fase-1--modelagem-e-design)
- ✅ [Fase 2 — Estrutura do Backend](#fase-2--estrutura-do-backend)
- ✅ [Fase 3 — Banco de Dados](#fase-3--banco-de-dados)
- ✅ [Fase 4 — Autenticação e RBAC](#fase-4--autenticação-e-rbac)
- ✅ [Fase 5 — Módulo de Projetos + State Machine](#fase-5--módulo-de-projetos--state-machine)
- ✅ [Fase 6 — Upload de Evidências](#fase-6--upload-de-evidências)
- ✅ [Fase 7 — POC do Stripe Connect (Escrow)](#fase-7--poc-do-stripe-connect-escrow)
- ✅ [Fase 8 — Matching e Contratos](#fase-8--matching-e-contratos)
- ✅ [Fase 9 — Validação de Fases + Liberação de Pagamento](#fase-9--validação-de-fases--liberação-de-pagamento)
- ✅ [Fase 10 — Notificações Push](#fase-10--notificações-push)
- [Fase 11 — Flutter App Cliente](#fase-11--flutter-app-cliente)
- [Fase 12 — Flutter App Trabalhador](#fase-12--flutter-app-trabalhador)
- [Fase 13 — React Admin Panel](#fase-13--react-admin-panel)
- [Fase 14 — Deploy do MVP](#fase-14--deploy-do-mvp)
- [Fase 15 — Materials Hub (Pós-MVP)](#fase-15--materials-hub-pós-mvp)

---

## ✅ Fase 0 — Preparação do Ambiente

**Duração estimada: 1 dia** → ✅ **Concluída**

### ✅ 0.1 Instalar ferramentas essenciais

| Ferramenta | Versão | Status |
|---|---|---|
| **Node.js** | v24.14.0 | ✅ |
| **npm** | 11.9.0 | ✅ |
| **Git** | 2.53.0 | ✅ |
| **NestJS CLI** | 11.0.21 | ✅ |
| **Flutter** | 3.41.7 (stable) | ✅ (`C:\src\flutter`) |
| **ANDROID_HOME** | Configurado | ✅ |

### ✅ 0.2 Criar contas nos serviços

| Serviço | URL | Para que serve | Status |
|---|---|---|---|
| GitHub | github.com | Código + CI/CD | ✅ `Mozezx/OxFieldServices` |
| Supabase | supabase.com | DB + Auth + Storage | ✅ |
| Railway | railway.app | Deploy backend | ⏳ (Fase 14) |
| Stripe | stripe.com | Pagamentos + Escrow | ✅ (modo Test) |
| Vercel | vercel.com | Deploy React admin | ⏳ (Fase 14) |
| Firebase | firebase.google.com | Push notifications | ✅ |
| Sentry | sentry.io | Monitoramento de erros | ⏳ (Fase 14) |

> **Importante:** No Stripe, crie a conta em modo **Test** primeiro. Só ative produção quando o MVP estiver validado.

### ✅ 0.3 Instalar ferramentas de produtividade

- **VSCode** — Extensões instaladas: ✅ ESLint, ✅ Prettier, ✅ Prisma, ✅ Thunder Client, ✅ Bruno API Client
- **TablePlus** ou **DBeaver** — ⏳ (instalar quando necessário)
- **Bruno** — ✅ (extensão VSCode instalada)
- **dbdiagram.io** — 🔗 online (usar na Fase 1)

### ✅ 0.4 Configurar repositório

Repositório configurado como **monorepo**:

```
https://github.com/Mozezx/OxFieldServices.git

ox-field-services-3/
  ├── .gitignore
  ├── README.md
  ├── ox-passo-a-passo.md
  ├── ox-backend/        # NestJS API
  ├── ox-admin/          # React Admin
  ├── ox-app-client/     # Flutter Cliente
  └── ox-app-worker/     # Flutter Trabalhador
```

✅ Primeiro commit realizado e enviado para o `main`.

---

## ✅ Fase 1 — Modelagem e Design

**Duração estimada: 2–3 dias** → ✅ **Concluída** (wireframes ignorados — seguido para vibe coding)
> Não escreva uma linha de código sem terminar esta fase.

### ✅ 1.1 Modelar o banco de dados (ERD)

Arquivo gerado em `docs/erd.dbml`. Cole o conteúdo em **dbdiagram.io** para visualizar.

Acesse **dbdiagram.io** e modele as tabelas abaixo:

```sql
-- Cole no dbdiagram.io para visualizar

Table users {
  id          uuid [pk, default: `gen_random_uuid()`]
  role        varchar [note: 'client | worker | admin']
  name        varchar
  email       varchar [unique]
  phone       varchar
  created_at  timestamp
}

Table workers {
  id                uuid [pk]
  user_id           uuid [ref: > users.id]
  skills            text[]
  rating            decimal
  shelter_certified boolean
  available         boolean
}

Table projects {
  id          uuid [pk]
  client_id   uuid [ref: > users.id]
  status      varchar [note: 'draft|in_validation|matched|contract_signed|active_escrow|in_execution|closing|closed']
  title       varchar
  budget      decimal
  location    varchar
  deadline    date
  created_at  timestamp
}

Table project_phases {
  id          uuid [pk]
  project_id  uuid [ref: > projects.id]
  name        varchar
  status      varchar [note: 'pending|in_progress|evidence_uploaded|under_review|validated|rejected']
  order       integer
  amount      decimal
}

Table phase_evidence {
  id          uuid [pk]
  phase_id    uuid [ref: > project_phases.id]
  type        varchar [note: 'photo|video']
  url         varchar
  uploaded_by uuid [ref: > users.id]
  uploaded_at timestamp
}

Table contracts {
  id               uuid [pk]
  project_id       uuid [ref: > projects.id]
  worker_id        uuid [ref: > workers.id]
  total_amount     decimal
  stripe_intent_id varchar
  signed_at        timestamp
}

Table escrow_txns {
  id          uuid [pk]
  contract_id uuid [ref: > contracts.id]
  amount      decimal
  status      varchar [note: 'held|released|refunded']
  released_at timestamp
}

Table payments {
  id                 uuid [pk]
  escrow_id          uuid [ref: > escrow_txns.id]
  recipient_type     varchar [note: 'worker|supplier|platform']
  recipient_id       uuid
  amount             decimal
  stripe_transfer_id varchar
  paid_at            timestamp
}

Table worker_ratings {
  id         uuid [pk]
  worker_id  uuid [ref: > workers.id]
  project_id uuid [ref: > projects.id]
  score      integer
  feedback   text
  created_at timestamp
}
```

### ✅ 1.2 Documentar os endpoints (API-First)

Arquivo gerado em `docs/openapi.yaml`. Visualize em **editor.swagger.io** (cole o conteúdo do arquivo).

Antes de codificar, defina os contratos da API. Use o **Swagger Editor** online (editor.swagger.io) ou um arquivo `openapi.yaml`:

```yaml
# Endpoints essenciais do MVP

POST   /auth/register
POST   /auth/login
POST   /auth/refresh

POST   /projects                    # criar projeto
GET    /projects/:id                # detalhes
PATCH  /projects/:id/status         # mudar estado

GET    /projects/:id/phases         # listar fases
PATCH  /phases/:id/status           # atualizar fase
POST   /phases/:id/evidence         # upload de prova

POST   /matching/:projectId         # rodar matching
POST   /contracts                   # criar contrato
POST   /contracts/:id/sign          # assinar

POST   /payments/create-intent      # criar escrow
POST   /payments/release/:phaseId   # liberar pagamento

GET    /workers/me                  # perfil do worker
PATCH  /workers/me                  # atualizar perfil
```

### ~~1.3 Wireframes das telas principais~~

> **Ignorado** — produto suficientemente claro para seguir com vibe coding.

Use o **Figma** (figma.com — grátis) e crie telas rápidas para:

**App Cliente:**
- Tela de login
- Lista de projetos
- Criar projeto (formulário)
- Detalhe do projeto (fases + status)
- Tela de validação de fase (ver fotos, aprovar/rejeitar)
- Pagamento / escrow

**App Trabalhador:**
- Dashboard de jobs disponíveis
- Detalhes de um job
- Upload de evidências
- Status de pagamentos

**Admin Web:**
- Lista de projetos em validação
- Detalhe de projeto
- Painel de workers
- Relatório de pagamentos

---

## ✅ Fase 2 — Estrutura do Backend

**Duração estimada: 1 dia** → ✅ **Concluída**

### ✅ 2.1 Criar o projeto NestJS

```bash
nest new ox-backend
cd ox-backend

# Escolha: npm

# Instalar dependências base
npm install @prisma/client prisma
npm install @nestjs/config @nestjs/jwt @nestjs/passport
npm install passport passport-jwt passport-local
npm install bcryptjs class-validator class-transformer
npm install @nestjs/swagger swagger-ui-express
npm install xstate
npm install @nestjs/bull bull
npm install ioredis
npm install stripe
npm install @supabase/supabase-js

npm install -D @types/bcryptjs @types/passport-jwt
```

### ✅ 2.2 Estrutura de pastas final

```bash
# Criar a estrutura de módulos
mkdir -p src/modules/{auth,users,projects,phases,matching,contracts,escrow,payments,notifications,workers}
mkdir -p src/common/{guards,decorators,filters,interceptors,pipes,state-machine,events}
mkdir -p src/config
```

### ✅ 2.3 Configuração base (`.env`)

```env
# .env (NUNCA commitar no git)

# App
NODE_ENV=development
PORT=3000

# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJxxxxx
DATABASE_URL=postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres

# JWT
JWT_SECRET=seu_secret_muito_longo_aqui
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=outro_secret_aqui
JWT_REFRESH_EXPIRES_IN=7d

# Stripe
STRIPE_SECRET_KEY=sk_test_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx

# Redis (Railway)
REDIS_URL=redis://default:xxxxx@xxxxx.railway.app:6379

# Firebase
FIREBASE_PROJECT_ID=ox-field-service
FIREBASE_PRIVATE_KEY=xxxxx
FIREBASE_CLIENT_EMAIL=xxxxx
```

```bash
# .env deve estar no .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
```

### ✅ 2.4 Configurar Swagger (documentação automática)

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validação global de DTOs
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  // Swagger
  const config = new DocumentBuilder()
    .setTitle('OX Field Service API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(3000);
  console.log('🚀 OX API rodando em http://localhost:3000');
  console.log('📄 Docs em http://localhost:3000/api/docs');
}
bootstrap();
```

---

## ✅ Fase 3 — Banco de Dados

**Duração estimada: 1–2 dias** → ✅ **Concluída**

> **Setup MCP Supabase:** `.mcp.json` e `.claude/settings.json` configurados. Reiniciar sessão para ativar — Claude aplicará as migrations diretamente via MCP sem precisar de credenciais manuais.

### 3.1 Configurar Prisma com Supabase

```bash
npx prisma init
```

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum UserRole {
  client
  worker
  admin
}

enum ProjectStatus {
  draft
  in_validation
  matched
  contract_signed
  active_escrow
  in_execution
  closing
  closed
  rejected
}

enum PhaseStatus {
  pending
  in_progress
  evidence_uploaded
  under_review
  validated
  rejected
}

enum EscrowStatus {
  held
  released
  refunded
}

model User {
  id         String    @id @default(uuid())
  role       UserRole
  name       String
  email      String    @unique
  phone      String?
  password   String
  createdAt  DateTime  @default(now())

  projects   Project[]
  worker     Worker?
  evidences  PhaseEvidence[]
  ratings    WorkerRating[]
}

model Worker {
  id               String   @id @default(uuid())
  userId           String   @unique
  user             User     @relation(fields: [userId], references: [id])
  skills           String[]
  rating           Decimal  @default(0)
  shelterCertified Boolean  @default(false)
  available        Boolean  @default(true)

  contracts        Contract[]
  ratings          WorkerRating[]
}

model Project {
  id        String        @id @default(uuid())
  clientId  String
  client    User          @relation(fields: [clientId], references: [id])
  status    ProjectStatus @default(draft)
  title     String
  budget    Decimal
  location  String
  deadline  DateTime?
  createdAt DateTime      @default(now())

  phases    ProjectPhase[]
  contract  Contract?
}

model ProjectPhase {
  id        String      @id @default(uuid())
  projectId String
  project   Project     @relation(fields: [projectId], references: [id])
  name      String
  status    PhaseStatus @default(pending)
  order     Int
  amount    Decimal

  evidences PhaseEvidence[]
}

model PhaseEvidence {
  id          String       @id @default(uuid())
  phaseId     String
  phase       ProjectPhase @relation(fields: [phaseId], references: [id])
  type        String
  url         String
  uploadedBy  String
  uploader    User         @relation(fields: [uploadedBy], references: [id])
  uploadedAt  DateTime     @default(now())
}

model Contract {
  id              String    @id @default(uuid())
  projectId       String    @unique
  project         Project   @relation(fields: [projectId], references: [id])
  workerId        String
  worker          Worker    @relation(fields: [workerId], references: [id])
  totalAmount     Decimal
  stripeIntentId  String?
  signedAt        DateTime?

  escrow          EscrowTxn?
}

model EscrowTxn {
  id          String       @id @default(uuid())
  contractId  String       @unique
  contract    Contract     @relation(fields: [contractId], references: [id])
  amount      Decimal
  status      EscrowStatus @default(held)
  releasedAt  DateTime?

  payments    Payment[]
}

model Payment {
  id               String    @id @default(uuid())
  escrowId         String
  escrow           EscrowTxn @relation(fields: [escrowId], references: [id])
  recipientType    String
  recipientId      String
  amount           Decimal
  stripeTransferId String?
  paidAt           DateTime?
}

model WorkerRating {
  id        String   @id @default(uuid())
  workerId  String
  worker    Worker   @relation(fields: [workerId], references: [id])
  projectId String
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  score     Int
  feedback  String?
  createdAt DateTime @default(now())
}
```

```bash
# Aplicar no Supabase
npx prisma migrate dev --name init
npx prisma generate

# Visualizar o banco
npx prisma studio
```

---

## ✅ Fase 4 — Autenticação e RBAC

**Duração estimada: 1–2 dias** → ✅ **Concluída**

> **Decisão de arquitetura:** autenticação delegada ao **Supabase Auth**. O backend NestJS apenas valida o JWT emitido pelo Supabase — não gerencia senhas, tokens de refresh, nem fluxos de login.
>
> Fluxo: Flutter/Web → Supabase Auth SDK → JWT → NestJS valida com `SUPABASE_JWT_SECRET` → carrega perfil do banco.

### 4.1 Adicionar variáveis de ambiente

```env
# .env — acrescente esta variável
# Encontre em: Supabase Dashboard → Project Settings → API → JWT Secret
SUPABASE_JWT_SECRET=seu_jwt_secret_aqui
```

### 4.2 Criar o módulo de Auth

```bash
# Dentro de ox-backend
nest generate module modules/auth
nest generate service modules/auth
```

```typescript
// src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { SupabaseStrategy } from './supabase.strategy';

@Module({
  imports: [PassportModule],
  providers: [AuthService, SupabaseStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

### 4.3 Strategy para validar o JWT do Supabase

```typescript
// src/modules/auth/supabase.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../prisma/prisma.service';

interface SupabaseJwtPayload {
  sub: string;       // auth.users.id
  email: string;
  role: string;      // 'authenticated' (papel do Supabase, não o nosso)
  iat: number;
  exp: number;
}

@Injectable()
export class SupabaseStrategy extends PassportStrategy(Strategy, 'supabase') {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.SUPABASE_JWT_SECRET,
    });
  }

  async validate(payload: SupabaseJwtPayload) {
    const user = await this.prisma.user.findUnique({
      where: { authId: payload.sub },
    });

    if (!user) {
      throw new UnauthorizedException('Perfil não encontrado. Faça o registro.');
    }

    return user; // injetado em req.user em todas as rotas protegidas
  }
}
```

### 4.4 Guard de autenticação

```typescript
// src/common/guards/jwt-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('supabase') {}
```

### 4.5 Sincronizar perfil após primeiro login

O Supabase Auth cria o usuário em `auth.users`. Precisamos criar o registro em `public.User` na primeira vez que o usuário acessa a API.

**Opção A — Endpoint de sync (mais simples para MVP):**

```typescript
// src/modules/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  // Chamado pelo app após primeiro login no Supabase
  async syncProfile(authId: string, email: string, name: string, role: 'client' | 'worker') {
    return this.prisma.user.upsert({
      where: { authId },
      update: {},
      create: { authId, email, name, role },
    });
  }
}
```

```typescript
// src/modules/auth/auth.controller.ts
import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  // POST /auth/sync — chamado pelo app logo após signup no Supabase
  @Post('sync')
  @UseGuards(JwtAuthGuard)
  syncProfile(
    @Req() req: any,
    @Body() body: { name: string; role: 'client' | 'worker' },
  ) {
    return this.authService.syncProfile(req.user.authId, req.user.email, body.name, body.role);
  }

  // GET /auth/me — retorna o perfil do usuário logado
  @UseGuards(JwtAuthGuard)
  @Post('me')
  me(@Req() req: any) {
    return req.user;
  }
}
```

### 4.6 Guards de RBAC

```typescript
// src/common/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.includes(user.role);
  }
}
```

```typescript
// src/common/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// Uso combinado nas rotas:
// @UseGuards(JwtAuthGuard, RolesGuard)
// @Roles('admin', 'client')
// @Get('/projects')
// findAll() { ... }
```

### 4.7 Registrar AuthModule no AppModule

```typescript
// src/app.module.ts — adicionar AuthModule aos imports
import { AuthModule } from './modules/auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
  ],
  ...
})
```

### 4.8 Testar com Bruno / Thunder Client

```
# 1. Registrar usuário via Supabase Auth (direto na API do Supabase)
POST https://pmsccdvhhhokormlvxww.supabase.co/auth/v1/signup
Content-Type: application/json
apikey: <SUPABASE_ANON_KEY>

{ "email": "test@ox.com", "password": "senha123" }

# 2. Copiar o access_token da resposta

# 3. Sincronizar perfil no backend
POST http://localhost:3000/auth/sync
Authorization: Bearer <access_token>

{ "name": "João Silva", "role": "client" }

# 4. Verificar perfil
POST http://localhost:3000/auth/me
Authorization: Bearer <access_token>
```

---

## ✅ Fase 5 — Módulo de Projetos + State Machine

**Duração estimada: 2–3 dias** → ✅ **Concluída (DeepSeek V4)**

> State machine implementada com XState v5, módulo Projects com CRUD completo + transições de estado, módulo Phases com validação de fluxo de fases.

### 5.1 Instalar e configurar XState

```bash
npm install xstate
```

```typescript
// src/common/state-machine/project.machine.ts

import { createMachine, interpret } from 'xstate';

export const projectMachine = createMachine({
  id: 'project',
  initial: 'draft',
  states: {
    draft:           { on: { SUBMIT:   'in_validation' } },
    in_validation:   { on: { APPROVE:  'matched', REJECT: 'rejected' } },
    matched:         { on: { ASSIGN:   'contract_signed' } },
    contract_signed: { on: { PAY:      'active_escrow' } },
    active_escrow:   { on: { START:    'in_execution' } },
    in_execution:    { on: { COMPLETE: 'closing' } },
    closing:         { on: { CONFIRM:  'closed' } },
    closed:          { type: 'final' },
    rejected:        { type: 'final' },
  },
});

// Função helper para validar transição
export function canTransition(currentStatus: string, event: string): boolean {
  const service = interpret(projectMachine);
  service.start(currentStatus as any);
  const nextState = service.machine.transition(currentStatus, { type: event });
  return nextState.value !== currentStatus;
}
```

### 5.2 Usar no service de projetos

```typescript
// src/modules/projects/projects.service.ts

async updateStatus(projectId: string, event: string, userId: string) {
  const project = await this.prisma.project.findUnique({ where: { id: projectId } });

  if (!canTransition(project.status, event)) {
    throw new BadRequestException(
      `Transição inválida: ${project.status} → ${event}`
    );
  }

  const machine = interpret(projectMachine).start(project.status as any);
  machine.send({ type: event });
  const newStatus = machine.state.value as string;

  return this.prisma.project.update({
    where: { id: projectId },
    data: { status: newStatus as any },
  });
}
```

---

## ✅ Fase 6 — Upload de Evidências

**Duração estimada: 1 dia** → ✅ **Concluída**

### 6.1 Configurar Supabase Storage

```typescript
// src/modules/phases/evidence.service.ts

import { createClient } from '@supabase/supabase-js';

@Injectable()
export class EvidenceService {
  private supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  async uploadEvidence(phaseId: string, file: Express.Multer.File, userId: string) {
    const fileName = `phases/${phaseId}/${Date.now()}-${file.originalname}`;

    // Upload para Supabase Storage
    const { data, error } = await this.supabase.storage
      .from('evidences')
      .upload(fileName, file.buffer, { contentType: file.mimetype });

    if (error) throw new InternalServerErrorException('Erro no upload');

    // URL pública
    const { data: { publicUrl } } = this.supabase.storage
      .from('evidences')
      .getPublicUrl(fileName);

    // Salvar referência no banco
    return this.prisma.phaseEvidence.create({
      data: { phaseId, type: file.mimetype, url: publicUrl, uploadedBy: userId }
    });
  }
}
```

### 6.2 Regra crítica

```typescript
// NUNCA permita validação de fase sem evidência
async validatePhase(phaseId: string) {
  const evidences = await this.prisma.phaseEvidence.findMany({
    where: { phaseId }
  });

  if (evidences.length === 0) {
    throw new BadRequestException('Sem evidências. Upload obrigatório antes de validar.');
  }

  // Continua...
}
```

---

## ✅ Fase 7 — POC do Stripe Connect (Escrow)

**Duração estimada: 3–4 dias** → ✅ **Concluída**
> Esta é a fase mais crítica. Testar exaustivamente antes de avançar.

### 7.1 Configurar Stripe Connect

```bash
# No dashboard do Stripe:
# 1. Ativar Stripe Connect (Connect > Get started)
# 2. Configurar como "Platform" (você é a plataforma OX)
# 3. Workers e fornecedores serão "Connected Accounts"
```

```typescript
// src/modules/payments/stripe.service.ts

import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
      apiVersion: '2023-10-16',
    });
  }

  // 1. Criar conta para worker (Connected Account)
  async createWorkerAccount(workerId: string, email: string) {
    const account = await this.stripe.accounts.create({
      type: 'express',
      email,
      metadata: { workerId },
    });
    return account;
  }

  // 2. Criar Payment Intent (bloquear dinheiro no escrow)
  async createEscrowIntent(amount: number, contractId: string) {
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: amount * 100, // centavos
      currency: 'eur',
      capture_method: 'manual', // bloqueia, não captura
      metadata: { contractId },
    });
    return paymentIntent;
  }

  // 3. Capturar (confirmar) o escrow após contrato assinado
  async captureEscrow(paymentIntentId: string) {
    return this.stripe.paymentIntents.capture(paymentIntentId);
  }

  // 4. Liberar pagamento (split automático após validação)
  async releaseSplitPayment(escrowTxnId: string, contractId: string) {
    // Buscar valores do DB
    const escrow = await this.prisma.escrowTxn.findUnique({
      where: { id: escrowTxnId },
      include: { contract: { include: { worker: true } } },
    });

    const total = Number(escrow.amount);

    // Split: 70% worker / 20% fornecedor / 10% OX
    const workerAmount  = Math.floor(total * 0.70 * 100); // centavos
    const supplierAmount = Math.floor(total * 0.20 * 100);
    // OX retém os 10% restantes automaticamente

    // Transfer para worker
    await this.stripe.transfers.create(
      {
        amount: workerAmount,
        currency: 'eur',
        destination: escrow.contract.worker.stripeAccountId,
        metadata: { escrowTxnId, type: 'worker' },
      },
      { idempotencyKey: `worker_${escrowTxnId}` } // evita duplicatas
    );

    // Transfer para fornecedor (se houver)
    // await this.stripe.transfers.create(...);

    // Marcar escrow como liberado
    await this.prisma.escrowTxn.update({
      where: { id: escrowTxnId },
      data: { status: 'released', releasedAt: new Date() },
    });
  }
}
```

### 7.2 Webhook do Stripe (crítico)

```typescript
// src/modules/payments/stripe-webhook.controller.ts

@Controller('webhooks')
export class StripeWebhookController {
  @Post('stripe')
  @HttpCode(200)
  async handleWebhook(@Req() req: RawBodyRequest<Request>, @Headers('stripe-signature') sig: string) {

    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET
      );
    } catch {
      throw new BadRequestException('Webhook signature inválida');
    }

    switch (event.type) {
      case 'payment_intent.succeeded':
        // Dinheiro confirmado no escrow → ativar projeto
        await this.paymentsService.activateEscrow(event.data.object.metadata.contractId);
        break;

      case 'transfer.created':
        // Worker recebeu → registrar no banco
        break;
    }

    return { received: true };
  }
}
```

### 7.3 Testar o fluxo completo (Stripe Test Mode)

```bash
# Instalar Stripe CLI para receber webhooks localmente
stripe listen --forward-to localhost:3000/webhooks/stripe

# Simular pagamentos de teste
stripe trigger payment_intent.succeeded

# Cartões de teste:
# Aprovado:  4242 4242 4242 4242
# Recusado:  4000 0000 0000 0002
```

---

## ✅ Fase 8 — Matching e Contratos

**Duração estimada: 2 dias** → ✅ **Concluída**

### 8.1 Matching Manual (MVP)

```typescript
// src/modules/matching/matching.service.ts
// Versão simples — sem IA no início

async findCandidates(projectId: string): Promise<Worker[]> {
  const project = await this.prisma.project.findUnique({
    where: { id: projectId }
  });

  // Critérios básicos de matching
  return this.prisma.worker.findMany({
    where: {
      available: true,
      shelterCertified: true,
      rating: { gte: 3.5 },
      // Futuramente: filtrar por localização e skills
    },
    orderBy: { rating: 'desc' },
    take: 5, // máximo 5 candidatos
  });
}
```

### 8.2 Contrato Digital

```typescript
// Quando worker aceita o job:
async createContract(projectId: string, workerId: string) {
  // 1. Buscar fase do projeto
  const project = await this.prisma.project.findUnique({
    where: { id: projectId },
    include: { phases: true }
  });

  // 2. Calcular total
  const totalAmount = project.phases.reduce((sum, p) => sum + Number(p.amount), 0);

  // 3. Criar contrato
  const contract = await this.prisma.contract.create({
    data: { projectId, workerId, totalAmount }
  });

  // 4. Transição de estado do projeto
  await this.projectsService.updateStatus(projectId, 'ASSIGN');

  return contract;
}
```

---

## ✅ Fase 9 — Validação de Fases + Liberação de Pagamento

**Duração estimada: 2 dias** → ✅ **Concluída**

### 9.1 Fluxo completo de validação

```typescript
// src/modules/phases/phases.service.ts

async validatePhase(phaseId: string, approved: boolean, clientId: string) {
  // 1. Verificar que cliente é dono do projeto
  const phase = await this.prisma.projectPhase.findUnique({
    where: { id: phaseId },
    include: { project: true, evidences: true }
  });

  if (phase.project.clientId !== clientId) {
    throw new ForbiddenException('Acesso negado');
  }

  // 2. Obrigatório ter evidências
  if (phase.evidences.length === 0) {
    throw new BadRequestException('Sem evidências para validar');
  }

  // 3. Fase deve estar em under_review
  if (phase.status !== 'under_review') {
    throw new BadRequestException('Fase não está em revisão');
  }

  if (approved) {
    // 4a. Aprovar → validated + disparar evento
    await this.prisma.projectPhase.update({
      where: { id: phaseId },
      data: { status: 'validated' }
    });

    // 5. Disparar evento de pagamento
    await this.eventBus.emit('phase.validated', { phaseId });

  } else {
    // 4b. Rejeitar → worker deve refazer
    await this.prisma.projectPhase.update({
      where: { id: phaseId },
      data: { status: 'rejected' }
    });
  }
}
```

### 9.2 Handler do evento: liberar pagamento

```typescript
// src/common/events/phase-validated.handler.ts

@OnEvent('phase.validated')
async handlePhaseValidated(payload: { phaseId: string }) {
  const phase = await this.prisma.projectPhase.findUnique({
    where: { id: payload.phaseId },
    include: {
      project: {
        include: { contract: { include: { escrow: true } } }
      }
    }
  });

  // Verificar se TODAS as fases foram validadas
  const allPhases = await this.prisma.projectPhase.findMany({
    where: { projectId: phase.projectId }
  });

  const allValidated = allPhases.every(p => p.status === 'validated');

  if (allValidated) {
    // Liberar pagamento completo
    await this.stripeService.releaseSplitPayment(
      phase.project.contract.escrow.id,
      phase.project.contract.id
    );

    // Fechar projeto
    await this.projectsService.updateStatus(phase.projectId, 'COMPLETE');
  }
}
```

---

## Fase 10 — Notificações Push

**Duração estimada: 1 dia**

**Status:** ✅ Concluída

**Implementado nesta fase:**

- Integração de [`firebase-admin`](ox-backend/package.json:34) no backend.
- Criação de [`NotificationsModule`](ox-backend/src/modules/notifications/notifications.module.ts), [`NotificationsService`](ox-backend/src/modules/notifications/notifications.service.ts) e listeners de eventos.
- Escuta dos eventos [`phase.validated`](ox-backend/src/modules/notifications/notifications.listeners.ts:9), [`phase.rejected`](ox-backend/src/modules/notifications/notifications.listeners.ts:14) e [`payment.released`](ox-backend/src/modules/notifications/notifications.listeners.ts:19).
- Inclusão do campo [`fcmToken`](ox-backend/prisma/schema.prisma:50) em [`User`](ox-backend/prisma/schema.prisma:43).
- Criação do endpoint [`PATCH /users/fcm-token`](ox-backend/src/modules/users/users.controller.ts:13) para registro do token do dispositivo.
- Garantia de resiliência com [`try/catch`](ox-backend/src/modules/notifications/notifications.service.ts:45) silencioso para que falhas de push não quebrem o fluxo principal.

**Observação importante:**

- A migration do Prisma para [`fcmToken`](ox-backend/prisma/schema.prisma:50) foi criada em [`20260501001000_add_user_fcm_token/migration.sql`](ox-backend/prisma/migrations/20260501001000_add_user_fcm_token/migration.sql), porém [`prisma migrate dev`](ox-backend/package.json:9) não pôde ser concluído no banco atual por causa de drift já existente no ambiente Supabase. O código foi ajustado, o Prisma Client foi regenerado com sucesso e o build foi validado, mas a aplicação dessa migration no banco precisa seguir a estratégia adotada pelo projeto para tratar esse drift sem reset do schema.

### 10.1 Configurar Firebase Admin

```bash
npm install firebase-admin
```

```typescript
// src/modules/notifications/notifications.service.ts

import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService {
  constructor() {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        }),
      });
    }
  }

  async sendPush(token: string, title: string, body: string, data?: Record<string, string>) {
    try {
      await admin.messaging().send({
        token,
        notification: { title, body },
        data,
      });
    } catch (error) {
      console.error('Erro FCM:', error);
      // Não joga erro — notificação não é crítica
    }
  }
}
```

---

## Fase 11 — Flutter App Cliente

**Duração estimada: 1–2 semanas**

### 11.1 Criar o projeto Flutter

```bash
flutter create ox_app_client
cd ox_app_client

# Adicionar dependências no pubspec.yaml
flutter pub add dio           # HTTP client
flutter pub add go_router     # navegação
flutter pub add riverpod      # state management
flutter pub add flutter_riverpod
flutter pub add image_picker  # upload de fotos
flutter pub add firebase_core
flutter pub add firebase_messaging
flutter pub add shared_preferences
flutter pub add intl          # formatação de datas/moedas
```

### 11.2 Estrutura de pastas Flutter

```
lib/
  core/
    api/         # cliente HTTP (Dio + interceptors)
    auth/        # token storage
    router/      # go_router config
  features/
    auth/        # login, registro
    projects/    # criar, listar, detalhe
    phases/      # upload evidências, validar
    payments/    # escrow, status
  shared/
    widgets/     # componentes reutilizáveis
    theme/       # cores, tipografia
```

### 11.3 Configurar Dio com interceptor de auth

```dart
// lib/core/api/api_client.dart

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.ox-service.com'));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Tentar refresh token
          await AuthService.refreshToken();
          return handler.resolve(await _retry(error.requestOptions));
        }
        return handler.next(error);
      },
    ));
  }
}
```

### 11.4 Telas prioritárias para o MVP

Implemente nesta ordem:

1. Login / Registro
2. Lista de projetos do cliente
3. Criar projeto (formulário + upload fotos)
4. Detalhe do projeto com status das fases
5. Tela de validação de fase (ver fotos do worker, aprovar/rejeitar)
6. Tela de pagamento / status do escrow

---

## Fase 12 — Flutter App Trabalhador

**Duração estimada: 1 semana**

```bash
flutter create ox_app_worker
# Mesmas dependências do app cliente
```

### Telas prioritárias

1. Login
2. Dashboard de jobs disponíveis (com matching)
3. Detalhe de um job (aceitar/recusar)
4. Tela de execução de fase + upload de fotos/vídeo
5. Preencher checklist da fase
6. Histórico de pagamentos recebidos
7. Perfil e rating

---

## Fase 13 — React Admin Panel

**Duração estimada: 1 semana**

```bash
npx create-next-app@latest ox-admin --typescript --tailwind --app
cd ox-admin

npm install axios
npm install @tanstack/react-query
npm install recharts        # gráficos
npm install lucide-react    # ícones
```

### Páginas prioritárias

1. `/login` — autenticação admin
2. `/projects` — lista com filtro por status
3. `/projects/[id]` — detalhe + mudar status manualmente
4. `/workers` — lista de trabalhadores + ratings
5. `/payments` — relatório financeiro (escrow, splits)
6. `/matching/[projectId]` — ver candidatos + atribuir manualmente

---

## Fase 14 — Deploy do MVP

**Duração estimada: 1–2 dias**

### 14.1 Deploy do Backend no Railway

```bash
# 1. Criar conta em railway.app
# 2. Instalar Railway CLI
npm install -g @railway/cli
railway login

# 3. No diretório do backend
railway init
railway up

# 4. Configurar variáveis de ambiente no dashboard Railway
#    (copiar todas as variáveis do .env)

# 5. Adicionar Redis
railway add --plugin redis
```

```dockerfile
# Dockerfile (Railway detecta automaticamente)
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### 14.2 Deploy do Admin no Vercel

```bash
# 1. No diretório do React admin
npm install -g vercel
vercel login
vercel --prod

# 2. Configurar variáveis de ambiente no dashboard Vercel
#    NEXT_PUBLIC_API_URL=https://sua-api.railway.app
```

### 14.3 Configurar GitHub Actions (CI/CD)

```yaml
# .github/workflows/deploy.yml

name: Deploy Backend

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Deploy to Railway
        run: |
          npm install -g @railway/cli
          railway up --detach
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

### 14.4 Checklist pré-lançamento

```
✅ Variáveis de ambiente configuradas em produção
✅ Stripe em modo LIVE (não test)
✅ Webhook URL do Stripe apontando para produção
✅ Supabase Row Level Security (RLS) ativado
✅ CORS configurado para domínios de produção
✅ Rate limiting ativado na API
✅ HTTPS em todos os endpoints
✅ Sentry configurado e recebendo erros
✅ UptimeRobot monitorando a API
✅ Backup automático do banco ativado (Supabase faz isso)
✅ Testes do fluxo completo em produção (criar projeto → validar → pagar)
```

---

## Fase 15 — Materials Hub (Pós-MVP)

**Duração estimada: 3–4 semanas**
> Só inicie após o MVP estar validado com usuários reais.

### Ordem de desenvolvimento

1. **Schema do banco** — tabelas `materials`, `suppliers`, `orders`, `deliveries`
2. **Catálogo estático** — CRUD de materiais por fase
3. **Portal de fornecedor** — backend para fornecedores gerenciarem stock
4. **Fluxo de pedido** — vinculado às fases do projeto
5. **Tracking de entrega** — status e confirmação na obra
6. **Replacement Engine** — alerta + proposta automática de substituto
7. **Rating de fornecedor** — alimentado por cada entrega

---

## Referência Rápida — Comandos do Dia a Dia

```bash
# Backend
npm run start:dev          # iniciar em modo watch
npx prisma studio          # visualizar banco
npx prisma migrate dev     # nova migration
npx prisma generate        # regenerar client após schema mudar
npm test                   # rodar testes
stripe listen --forward-to localhost:3000/webhooks/stripe  # webhooks locais

# Flutter
flutter run                # rodar no emulador
flutter pub get            # instalar dependências
flutter build apk          # gerar APK Android
flutter build ios          # gerar iOS

# React Admin
npm run dev                # iniciar em dev
npm run build              # build de produção
vercel --prod              # deploy

# Git
git checkout -b feature/nome-da-feature    # nova branch
git push origin feature/nome-da-feature    # push
# Abrir Pull Request no GitHub → merge na main → deploy automático
```

---

## Resumo das Fases e Prazos

| Fase | O que entrega | Semanas | Status |
|---|---|---|---|
| 0 | Ambiente pronto | 1 | ✅ |
| 1 | ERD + endpoints documentados + wireframes | 1 | ✅ (wireframes ignorados) |
| 2–3 | Backend estruturado + banco configurado | 1 | ✅ Fase 2 · ✅ Fase 3 |
| 4 | Auth + RBAC funcionando | 1 | ✅ |
| ✅ 5–6 | Projetos + fases + upload de evidências | 1–2 | ✅ |
| ✅ 7 | Escrow + Stripe Connect funcionando | 1–2 | ✅ |
| ✅ 8 | Matching + contratos | 1–2 | ✅ |
| 9 | Validação de fases + liberação de pagamento | 1 |
| 10 | Notificações push | 0.5 |
| 11–12 | Apps Flutter (cliente + worker) | 3–4 |
| 13 | Admin React | 1 |
| 14 | Deploy MVP em produção | 0.5 |
| **Total MVP** | **Sistema funcionando end-to-end** | **~14–16 semanas** |
| 15+ | Materials Hub + melhorias | Pós-MVP |

---

*Guia de desenvolvimento OX Field Service · Solo Dev · Vibe Coding*
*Siga a ordem, não pule fases, e teste o Stripe antes de qualquer tela bonita.*
