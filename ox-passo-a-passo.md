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
- ✅ [Fase 11 — Flutter App Cliente](#fase-11--flutter-app-cliente)
- ✅ [Fase 12 — Flutter App Trabalhador](#fase-12--flutter-app-trabalhador)
- ✅ [Fase 13 — React Admin Panel](#fase-13--react-admin-panel)
- [Fase 14 — Deploy do MVP](#fase-14--deploy-do-mvp)
- [Fase 15 — Materials Hub (Pós-MVP)](#fase-15--materials-hub-pós-mvp)
- [Fase 16 — Time Tracking por Técnico/Fase (Pós-MVP)](#fase-16--time-tracking-por-técnicofase-pós-mvp)
- [Fase 17 — Geolocalização + Mapa em Tempo Real (Pós-MVP)](#fase-17--geolocalização--mapa-em-tempo-real-pós-mvp)

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

## ✅ Fase 10 — Notificações Push

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

## ✅ Fase 11 — Flutter App Cliente

**Duração estimada: 1–2 semanas** → ✅ **Concluída**

**Implementado nesta fase:**

- Design system completo: `AppColors`, `AppGradients`, `AppTheme` (Material 3 dark), `AppTextStyles`
- Widgets reutilizáveis: `OxButton` (3 variantes + isLoading), `OxInput` (com toggle de senha), `OxBadge` (5 estados), `OxAppBar`, `OxShimmerBox`/`OxProjectCardSkeleton`, `OxEmptyState`
- GoRouter com `ShellRoute`, guards de redirecionamento auth-aware via `authStateProvider`
- Supabase Flutter auth + Dio com interceptor JWT + Riverpod providers
- l10n com 68 chaves em PT-BR (`app_pt.arb`), esqueleto EN/NL
- Splash Screen com animação scale+fade
- Onboarding de 3 slides com `PageView` + estado persistido via `SharedPreferences`
- Login + Registro com `ConsumerStatefulWidget` e seletor de role (client/worker)
- Projects: lista com filtros + shimmer loading + FAB, detalhe com timeline de fases + botão de validação, wizard de criação em 3 passos
- Phases: detalhe com grid de evidências, validação com approve/reject + `AlertDialog` de confirmação
- Payments: card de escrow + breakdown 70/20/10
- `flutter analyze`: **0 issues**

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
flutter esta na pasta C:\src\flutter

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

## ✅ Fase 12 — Flutter App Trabalhador

**Duração estimada: 1 semana** → ✅ **Concluída**

**Implementado nesta fase:**

- Design System completo reutilizado do App Cliente: `AppColors`, `AppGradients`, `AppTheme` (Material 3 dark), widgets `OxButton`, `OxInput`, `OxBadge`, `OxAppBar`, `OxEmptyState`, `OxJobCardSkeleton`
- `GoRouter` com `ShellRoute`, guard de auth via Supabase session
- Bottom navigation com **4 tabs**: Jobs (briefcase), Em Execução (zap), Pagamentos (wallet), Perfil (user)
- Supabase Flutter auth + Dio com interceptor JWT + Riverpod providers
- **Splash Screen** com animação scale+fade
- **Auth**: Login + Registro (role fixo como `worker`) com validação inline
- **Jobs Dashboard** (`/home`): Toggle de disponibilidade on/off, rating em destaque, lista de jobs disponíveis com barra de compatibilidade (match score), lista de jobs ativos com botão "Continuar execução"
- **Job Detail** (`/jobs/:id`): Descrição, fases + valores, total, botões "Aceitar" (com dialog de confirmação) e "Recusar"
- **Phase Execution** (`/execution/:phaseId`): Checklist interativo da fase, grid de evidências carregadas, botão upload, botão "Enviar para Revisão" (desabilitado até 3 evidências) com dialog de confirmação
- **Upload Evidence** (`/execution/:phaseId/upload`): Câmera + galeria com `image_picker`, grid de preview, remoção individual, upload em batch
- **Payments History** (`/payments`): Card de total recebido em destaque (verde `#03FC30`), lista de transações com status
- **Worker Profile** (`/profile`): Avatar, rating com estrelas, disponibilidade, certificações, skills como chips, toggle de disponibilidade, logout com confirmação
- `flutter analyze`: **0 issues**

### Estrutura implementada

```
ox-app-worker/lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/        # AppColors, AppGradients, AppTheme (idêntico ao cliente)
│   ├── widgets/      # OxButton, OxInput, OxBadge, OxAppBar, OxEmptyState, OxJobCardSkeleton
│   ├── api/          # ApiClient (Dio + interceptor JWT), ApiEndpoints
│   ├── auth/         # auth_provider, token_storage
│   └── router/       # GoRouter + MainShell (4 tabs)
└── features/
    ├── splash/       # SplashScreen com animação
    ├── auth/         # login_screen, register_screen, auth_controller
    ├── jobs/         # jobs_dashboard_screen, job_detail_screen, jobs_provider
    ├── execution/    # phase_execution_screen, upload_evidence_screen, execution_provider
    ├── payments/     # payments_history_screen, payments_provider
    └── profile/      # worker_profile_screen, profile_provider
```

---

## ✅ Fase 13 — React Admin Panel

**Duração estimada: 1 semana** → ✅ **Concluída**

**Implementado nesta fase:**

- Projeto Next.js 14 (App Router) + TypeScript + Tailwind CSS em `ox-admin/`
- Design system OX: cores primárias (`#092F3D`, `#03FC30`, `#0D3F52`) configuradas no `tailwind.config.ts`
- Middleware Supabase SSR com proteção de rotas: não-autenticados → `/login`, admin logado → `/projects`
- **Lib layer:** `api.ts` (Axios + interceptor JWT), clientes Supabase (browser + server), `lib/auth.ts` (Server Actions), React Query hooks (`useProjects`, `useWorkers`, `usePayments`)
- **UI components:** `Button` (4 variantes), `Card`, `Badge` (9 status), `Input` (com toggle senha), `Table`, `Modal` (Framer Motion), `Skeleton` / `TableSkeleton`
- **Layout:** `Sidebar` colapsável (240px/64px), `Header`, `PageHeader`
- **Feature components:** `ProjectsTable`, `ProjectStatusSelect` (transições XState-aware), `PhaseTimeline`, `WorkersTable`, `WorkerRatingStars`, `PaymentsChart` (Recharts), `CandidatesCard`
- **Páginas:**
  - `/login` — tela de login com logo OX, fundo `#092F3D`, card `#0D3F52`
  - `/projects` — lista com filtro de status + busca + exportar CSV
  - `/projects/[id]` — detalhe com timeline de fases, evidências, ações de status
  - `/workers` — lista com busca por nome/skill, rating, disponibilidade
  - `/workers/[id]` — perfil completo com skills, certificações
  - `/payments` — 3 KPI cards, gráfico de barras semanal, tabela de transações
  - `/matching/[projectId]` — candidatos com barra de match %, atribuição com confirmação modal
- `react-hot-toast` integrado para feedback de ações

### Para instalar as dependências

```bash
cd ox-admin
npm install
npm run dev  # porta 3001
```

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

## Fase 16 — Time Tracking por Técnico/Fase (Pós-MVP)

**Duração estimada: 1–2 semanas**
> Só inicie após o MVP estar validado com usuários reais. Alimenta o matching com dados reais de desempenho.

### Objetivo

Registrar automaticamente quanto tempo cada técnico leva em cada fase, por tipo de projeto. Usar esse histórico para melhorar o algoritmo de matching (preferir técnicos mais rápidos e consistentes).

### 16.1 Schema — adicionar ao banco

```prisma
// Adicionar em ProjectPhase
model ProjectPhase {
  // ... campos existentes ...
  startedAt   DateTime?   // quando status mudou para in_progress
  completedAt DateTime?   // quando status mudou para validated
}

// Tabela de histórico de transições (auditoria completa)
model PhaseStatusHistory {
  id        String       @id @default(uuid())
  phaseId   String
  phase     ProjectPhase @relation(fields: [phaseId], references: [id])
  fromStatus String
  toStatus   String
  changedBy  String      // userId
  changedAt  DateTime    @default(now())
}
```

### 16.2 Capturar timestamps automaticamente

```typescript
// No phases.service.ts — ao mudar status da fase
async updatePhaseStatus(phaseId: string, newStatus: PhaseStatus, userId: string) {
  const data: any = { status: newStatus };

  if (newStatus === 'in_progress') data.startedAt = new Date();
  if (newStatus === 'validated')   data.completedAt = new Date();

  await this.prisma.projectPhase.update({ where: { id: phaseId }, data });

  // Registrar histórico
  await this.prisma.phaseStatusHistory.create({
    data: { phaseId, fromStatus: currentStatus, toStatus: newStatus, changedBy: userId }
  });
}
```

### 16.3 Algoritmo de métricas por técnico

```typescript
// src/modules/workers/worker-metrics.service.ts

async getWorkerPhaseMetrics(workerId: string) {
  const phases = await this.prisma.projectPhase.findMany({
    where: {
      status: 'validated',
      startedAt: { not: null },
      completedAt: { not: null },
      project: { contract: { workerId } },
    },
  });

  // Tempo médio por fase (em horas)
  const avgHours = phases.reduce((sum, p) => {
    const hours = (p.completedAt.getTime() - p.startedAt.getTime()) / 3_600_000;
    return sum + hours;
  }, 0) / phases.length;

  return { workerId, totalPhases: phases.length, avgHoursPerPhase: avgHours };
}
```

### 16.4 Integrar no Matching

```typescript
// Estender critérios do matching.service.ts
// Priorizar técnicos com menor tempo médio por fase + maior rating
orderBy: [{ rating: 'desc' }, { avgPhaseCompletionHours: 'asc' }]
```

### 16.5 Exibir no Admin Panel

- Tabela de técnicos com coluna "Tempo médio por fase"
- Gráfico de barras: comparação entre técnicos por tipo de obra
- Alertas para fases que passam do prazo estimado

---

## Fase 17 — Geolocalização + Mapa em Tempo Real (Pós-MVP)

**Duração estimada: 2–3 semanas**
> Depende do Admin Panel (Fase 13) estar concluído. Requer conta Google Cloud com Maps API ativada.

### Objetivo

1. **Geolocalização de evidências** — ao fazer upload de uma foto/vídeo, o app worker captura e persiste a coordenada GPS. O admin vê um mapa com pins de onde cada evidência foi registrada.
2. **Localização em tempo real** — o app worker transmite a posição do técnico periodicamente enquanto ele está com um job ativo. O admin monitora todos os técnicos em campo num mapa ao vivo.

### 17.1 APIs e serviços necessários

| Serviço | Para que serve | Custo |
|---|---|---|
| **Google Maps JavaScript API** | Mapa interativo no Admin React | Pago por carregamento |
| **Google Maps SDK Flutter** | Renderizar mapa no app worker | Grátis até 1k req/dia |
| **Geolocator (Flutter)** | Capturar GPS do dispositivo | Gratuito (pacote) |
| **Supabase Realtime** | Transmitir posição ao vivo via WebSocket | Incluso no plano |

```bash
# Google Cloud Console
# 1. Criar projeto → Ativar "Maps JavaScript API" e "Maps SDK for Android/iOS"
# 2. Gerar API Key → restringir por SHA-1 (Android) e Bundle ID (iOS)
# 3. Adicionar GOOGLE_MAPS_API_KEY no .env do backend e no Flutter
```

### 17.2 Schema — geolocalização nas evidências

```prisma
// Adicionar em PhaseEvidence
model PhaseEvidence {
  // ... campos existentes ...
  latitude   Float?
  longitude  Float?
  accuracy   Float?   // precisão em metros (útil para validar fraude)
}

// Nova tabela — posição em tempo real dos técnicos
model WorkerLocation {
  id        String   @id @default(uuid())
  workerId  String
  worker    Worker   @relation(fields: [workerId], references: [id])
  latitude  Float
  longitude Float
  accuracy  Float?
  recordedAt DateTime @default(now())

  @@index([workerId, recordedAt])
}
```

```bash
npx prisma migrate dev --name add_geolocation
```

### 17.3 Flutter — capturar GPS no upload de evidência

```yaml
# pubspec.yaml
dependencies:
  geolocator: ^12.0.0
  google_maps_flutter: ^2.9.0
```

```dart
// lib/features/execution/upload_evidence_screen.dart

import 'package:geolocator/geolocator.dart';

Future<Position?> _getCurrentPosition() async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) return null;
  return Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

Future<void> _uploadWithLocation(File file) async {
  final position = await _getCurrentPosition();
  await ref.read(executionProvider.notifier).uploadEvidence(
    file: file,
    latitude: position?.latitude,
    longitude: position?.longitude,
    accuracy: position?.accuracy,
  );
}
```

### 17.4 Flutter — transmitir posição em tempo real

```dart
// lib/core/location/location_service.dart
// Ativo apenas enquanto o worker tem um job com status in_progress

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  StreamSubscription<Position>? _sub;

  void startTracking(String workerId) {
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // só envia se mover mais de 20m
      ),
    ).listen((position) async {
      await Supabase.instance.client.from('worker_locations').insert({
        'worker_id': workerId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      });
    });
  }

  void stopTracking() => _sub?.cancel();
}
```

```dart
// Iniciar tracking ao aceitar job, parar ao concluir última fase
// lib/features/jobs/job_detail_screen.dart
ref.read(locationServiceProvider).startTracking(workerId);
```

### 17.5 Backend — endpoint para salvar localização

```typescript
// src/modules/workers/workers.controller.ts

@Post('location')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('worker')
async updateLocation(
  @Req() req: any,
  @Body() body: { latitude: number; longitude: number; accuracy?: number },
) {
  return this.workersService.saveLocation(req.user.id, body);
}

// src/modules/workers/workers.service.ts
async saveLocation(userId: string, dto: { latitude: number; longitude: number; accuracy?: number }) {
  const worker = await this.prisma.worker.findUnique({ where: { userId } });
  return this.prisma.workerLocation.create({
    data: { workerId: worker.id, ...dto },
  });
}

// Endpoint para o admin buscar última posição de cada técnico ativo
@Get('locations/live')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
async getLiveLocations() {
  // Última posição de cada worker nos últimos 10 minutos
  const since = new Date(Date.now() - 10 * 60 * 1000);
  return this.prisma.$queryRaw`
    SELECT DISTINCT ON (worker_id)
      worker_id, latitude, longitude, accuracy, recorded_at
    FROM worker_locations
    WHERE recorded_at > ${since}
    ORDER BY worker_id, recorded_at DESC
  `;
}
```

### 17.6 Admin Panel — mapa de evidências por fase

```tsx
// ox-admin/app/projects/[id]/map/page.tsx
// Instalar: npm install @react-google-maps/api

import { GoogleMap, Marker, InfoWindow } from '@react-google-maps/api';

export default function ProjectEvidenceMap({ evidences }) {
  return (
    <GoogleMap
      mapContainerStyle={{ width: '100%', height: '500px' }}
      center={{ lat: evidences[0].latitude, lng: evidences[0].longitude }}
      zoom={15}
    >
      {evidences.map((ev) => (
        <Marker
          key={ev.id}
          position={{ lat: ev.latitude, lng: ev.longitude }}
          label={ev.phase.name}
        />
      ))}
    </GoogleMap>
  );
}
```

### 17.7 Admin Panel — mapa de técnicos em tempo real

```tsx
// ox-admin/app/workers/live-map/page.tsx
// Usa Supabase Realtime para atualizar sem polling

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { GoogleMap, Marker } from '@react-google-maps/api';

export default function WorkerLiveMap() {
  const [locations, setLocations] = useState([]);

  useEffect(() => {
    // Carregar posições atuais
    fetchLiveLocations().then(setLocations);

    // Escutar novas inserções em tempo real
    const channel = supabase
      .channel('worker-locations')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'worker_locations',
      }, (payload) => {
        setLocations((prev) => {
          const updated = prev.filter(l => l.workerId !== payload.new.worker_id);
          return [...updated, payload.new];
        });
      })
      .subscribe();

    return () => supabase.removeChannel(channel);
  }, []);

  return (
    <GoogleMap mapContainerStyle={{ width: '100%', height: '70vh' }} zoom={12}>
      {locations.map((loc) => (
        <Marker
          key={loc.workerId}
          position={{ lat: loc.latitude, lng: loc.longitude }}
          title={loc.workerName}
          icon="/icons/worker-pin.png"
        />
      ))}
    </GoogleMap>
  );
}
```

### 17.8 Considerações de privacidade

- **Consentimento explícito:** exibir dialog ao primeiro login do worker explicando que a localização será compartilhada com o admin durante jobs ativos.
- **Tracking limitado:** só transmitir posição enquanto houver um job com status `in_progress`. Parar ao completar ou recusar.
- **Retenção de dados:** manter `worker_locations` por no máximo 90 dias (GDPR/LGPD). Criar job no Bull para limpeza periódica.
- **Precisão mínima:** ignorar registros com `accuracy > 50m` para evitar dados ruins num mapa.

### 17.9 Checklist de entrega

```
[ ] Google Maps API Key configurada (Android + iOS + Web)
[ ] Campo latitude/longitude em PhaseEvidence
[ ] Tabela WorkerLocation criada e indexada
[ ] Flutter captura GPS no upload de evidência
[ ] Flutter transmite posição a cada 20m de movimento
[ ] Backend salva localização e expõe endpoint /workers/locations/live
[ ] Admin: página de mapa por projeto com pins de evidências
[ ] Admin: página de mapa ao vivo com todos técnicos em campo
[ ] Supabase Realtime configurado na tabela worker_locations
[ ] Dialog de consentimento no app worker
[ ] Job de limpeza de localizações antigas (>90 dias)
```

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
| ✅ 11 | App Flutter Cliente | 1–2 | ✅ |
| ✅ 12 | App Flutter Trabalhador | 1–2 | ✅ |
| ✅ 13 | Admin React | 1 | ✅ |
| 14 | Deploy MVP em produção | 0.5 |
| **Total MVP** | **Sistema funcionando end-to-end** | **~14–16 semanas** |
| 15 | Materials Hub | Pós-MVP |
| 16 | Time Tracking por técnico/fase + métricas de matching | Pós-MVP |
| 17 | Geolocalização de evidências + mapa ao vivo de técnicos | Pós-MVP |

---

*Guia de desenvolvimento OX Field Service · Solo Dev · Vibe Coding*
*Siga a ordem, não pule fases, e teste o Stripe antes de qualquer tela bonita.*
