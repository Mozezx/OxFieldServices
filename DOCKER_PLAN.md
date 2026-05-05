# Plano de Dockerização — OX Field Services

## Contexto

Monorepo com 4 apps:

| App | Stack | Deploy |
|-----|-------|--------|
| `ox-backend` | NestJS 11, Node 20 | Container |
| `ox-admin` | Next.js 14 | Container |
| `ox-app-client` | Flutter | App stores (sem Docker) |
| `ox-app-worker` | Flutter | App stores (sem Docker) |

**Infraestrutura externa** (não dockerizada):
- **Supabase** — PostgreSQL, Auth, Storage, Realtime (hosted)
- **Stripe** — Pagamentos (hosted)
- **Firebase** — Push notifications (hosted)

---

## Arquitetura Docker

```
┌─────────────────────────────────────────────────┐
│               docker-compose.yml (root)          │
│                                                  │
│  ┌──────────────┐      ┌──────────────────────┐  │
│  │  ox-backend  │ ←──→ │        redis         │  │
│  │  (port 3000) │      │     (port 6379)      │  │
│  └──────┬───────┘      └──────────────────────┘  │
│         │                                        │
│  ┌──────▼───────┐                               │
│  │   ox-admin   │                               │
│  │  (port 3001) │                               │
│  └──────────────┘                               │
│                                                  │
│  [Supabase / Stripe / Firebase — externos]       │
└─────────────────────────────────────────────────┘
```

---

## Etapas

### Etapa 1 — Revisar e finalizar `ox-backend/Dockerfile`

O backend **já possui** um `Dockerfile` multi-stage funcional. Verificar e ajustar:

- [ ] Confirmar que o build multi-stage (builder → production) está correto
- [ ] Garantir que `scripts/start.sh` executa `prisma migrate deploy` antes do servidor
- [ ] Confirmar que `DIRECT_URL` (usado nas migrations) é injetado via env
- [ ] Health check apontando para `GET /health` (já configurado)
- [ ] Arquivo `.dockerignore` em `ox-backend/` cobrindo:
  ```
  node_modules/
  dist/
  .env
  .env.*
  !.env.example
  coverage/
  .git/
  ```

**Arquivo**: `ox-backend/Dockerfile` (já existe — apenas revisar)

---

### Etapa 2 — Criar `ox-admin/Dockerfile`

Next.js requer configuração específica para produção em container:

```dockerfile
# ox-admin/Dockerfile
FROM node:20-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# ── Dependências ──────────────────────────────────
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

# ── Build ─────────────────────────────────────────
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# NEXT_PUBLIC_* precisam estar disponíveis no build
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_FIREBASE_API_KEY
ARG NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN
ARG NEXT_PUBLIC_FIREBASE_PROJECT_ID
ARG NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET
ARG NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID
ARG NEXT_PUBLIC_FIREBASE_APP_ID
ARG NEXT_PUBLIC_FIREBASE_VAPID_KEY
RUN npm run build

# ── Produção ──────────────────────────────────────
FROM base AS runner
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid  1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3001
ENV PORT=3001
CMD ["node", "server.js"]
```

**Pré-requisito**: Habilitar `output: 'standalone'` no `ox-admin/next.config.mjs`:
```js
const nextConfig = {
  output: 'standalone',
  // ... resto da config
}
```

**Arquivo `.dockerignore`** em `ox-admin/`:
```
node_modules/
.next/
.env
.env.*
!.env.example
```

---

### Etapa 3 — Criar `docker-compose.yml` na raiz

Orquestrar todos os serviços web juntos a partir da raiz do monorepo:

```yaml
# docker-compose.yml (raiz)
name: ox-field-services

services:
  redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD:-redis_pass} --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - ox-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD:-redis_pass}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  ox-backend:
    build:
      context: ./ox-backend
      dockerfile: Dockerfile
    restart: unless-stopped
    depends_on:
      redis:
        condition: service_healthy
    env_file:
      - ./ox-backend/.env
    environment:
      NODE_ENV: production
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis_pass}@redis:6379
    ports:
      - "3000:3000"
    networks:
      - ox-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      start_period: 40s
      retries: 3

  ox-admin:
    build:
      context: ./ox-admin
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_SUPABASE_URL: ${NEXT_PUBLIC_SUPABASE_URL}
        NEXT_PUBLIC_SUPABASE_ANON_KEY: ${NEXT_PUBLIC_SUPABASE_ANON_KEY}
        NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:-http://ox-backend:3000}
        NEXT_PUBLIC_FIREBASE_API_KEY: ${NEXT_PUBLIC_FIREBASE_API_KEY}
        NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN: ${NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN}
        NEXT_PUBLIC_FIREBASE_PROJECT_ID: ${NEXT_PUBLIC_FIREBASE_PROJECT_ID}
        NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET: ${NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET}
        NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID: ${NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID}
        NEXT_PUBLIC_FIREBASE_APP_ID: ${NEXT_PUBLIC_FIREBASE_APP_ID}
        NEXT_PUBLIC_FIREBASE_VAPID_KEY: ${NEXT_PUBLIC_FIREBASE_VAPID_KEY}
    restart: unless-stopped
    depends_on:
      ox-backend:
        condition: service_healthy
    env_file:
      - ./ox-admin/.env
    ports:
      - "3001:3001"
    networks:
      - ox-network

volumes:
  redis_data:

networks:
  ox-network:
    driver: bridge
```

---

### Etapa 4 — Arquivo `.env` na raiz (para o compose)

Criar `.env.example` na raiz do monorepo com todas as variáveis consolidadas:

```env
# ── Redis ──────────────────────────────────────────
REDIS_PASSWORD=redis_pass

# ── Backend (ox-backend/.env) ──────────────────────
# (copiar conteúdo de ox-backend/.env.example)
NODE_ENV=production
PORT=3000
SUPABASE_URL=
SUPABASE_SERVICE_KEY=
DATABASE_URL=
DIRECT_URL=
JWT_SECRET=
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=
JWT_REFRESH_EXPIRES_IN=7d
APP_URL=
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_CHARGE_CURRENCY=brl
STRIPE_CONNECT_RETURN_URL=
STRIPE_CONNECT_REFRESH_URL=
STRIPE_CONNECT_APP_DEEP_LINK=
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# ── Admin (ox-admin/.env) ──────────────────────────
# (copiar conteúdo de ox-admin/.env.example)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
NEXT_PUBLIC_API_URL=http://ox-backend:3000
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_VAPID_KEY=
```

---

### Etapa 5 — GitHub Actions CI/CD

Criar pipeline para build e push das imagens ao GitHub Container Registry (ghcr.io):

**Arquivo**: `.github/workflows/docker.yml`

```yaml
name: Build & Push Docker Images

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  BACKEND_IMAGE: ghcr.io/${{ github.repository_owner }}/ox-backend
  ADMIN_IMAGE: ghcr.io/${{ github.repository_owner }}/ox-admin

jobs:
  build-backend:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ${{ env.BACKEND_IMAGE }}
          tags: |
            type=sha
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}
      - uses: docker/build-push-action@v5
        with:
          context: ./ox-backend
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  build-admin:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ${{ env.ADMIN_IMAGE }}
          tags: |
            type=sha
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}
      - uses: docker/build-push-action@v5
        with:
          context: ./ox-admin
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          build-args: |
            NEXT_PUBLIC_SUPABASE_URL=${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
            NEXT_PUBLIC_SUPABASE_ANON_KEY=${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
            NEXT_PUBLIC_API_URL=${{ secrets.NEXT_PUBLIC_API_URL }}
            NEXT_PUBLIC_FIREBASE_API_KEY=${{ secrets.NEXT_PUBLIC_FIREBASE_API_KEY }}
            NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=${{ secrets.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN }}
            NEXT_PUBLIC_FIREBASE_PROJECT_ID=${{ secrets.NEXT_PUBLIC_FIREBASE_PROJECT_ID }}
            NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=${{ secrets.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET }}
            NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=${{ secrets.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID }}
            NEXT_PUBLIC_FIREBASE_APP_ID=${{ secrets.NEXT_PUBLIC_FIREBASE_APP_ID }}
            NEXT_PUBLIC_FIREBASE_VAPID_KEY=${{ secrets.NEXT_PUBLIC_FIREBASE_VAPID_KEY }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

### Etapa 6 — Variáveis de ambiente no GitHub Secrets

Configurar no repositório GitHub → Settings → Secrets and variables → Actions:

| Secret | Descrição |
|--------|-----------|
| `NEXT_PUBLIC_SUPABASE_URL` | URL do projeto Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Chave anon do Supabase |
| `NEXT_PUBLIC_API_URL` | URL pública da API (ex: https://api.oxapp.com.br) |
| `NEXT_PUBLIC_FIREBASE_*` | Todas as configs Firebase Web |
| Demais secrets do backend | Stripe, JWT, Firebase Admin, etc. |

---

## Observações sobre Supabase

Como o Supabase é **hosted (externo)**, o Docker **não sobe banco de dados local**. O que o container do backend precisa:

1. **`DATABASE_URL`** — connection pooler do Supabase (PgBouncer) para queries em runtime
2. **`DIRECT_URL`** — conexão direta ao PostgreSQL para `prisma migrate deploy` no startup
3. **`SUPABASE_URL` + `SUPABASE_SERVICE_KEY`** — para Storage, Auth Admin e Realtime

> As migrations rodam automaticamente no startup via `scripts/start.sh` usando `DIRECT_URL`.

---

## Variáveis NEXT_PUBLIC_* no Next.js + Docker

Variáveis `NEXT_PUBLIC_*` são **embebidas no bundle JavaScript** durante o `next build`. Isso significa que elas precisam ser passadas como **build args** no Dockerfile — `env_file` no compose **não funciona** para elas.

O `ox-admin/Dockerfile` acima usa `ARG` para isso, e o compose passa via `build.args`.

---

## Comandos úteis

```bash
# Build e subir todos os serviços
docker compose up --build -d

# Ver logs
docker compose logs -f ox-backend
docker compose logs -f ox-admin

# Rodar migrations manualmente
docker compose exec ox-backend npx prisma migrate deploy

# Parar tudo
docker compose down

# Rebuild apenas um serviço
docker compose up --build -d ox-admin
```

---

## Checklist de implementação

- [ ] **Etapa 1** — Revisar `ox-backend/Dockerfile` e criar `.dockerignore`
- [ ] **Etapa 2** — Criar `ox-admin/Dockerfile` e `.dockerignore`
- [ ] **Etapa 2** — Adicionar `output: 'standalone'` em `ox-admin/next.config.mjs`
- [ ] **Etapa 3** — Criar `docker-compose.yml` na raiz
- [ ] **Etapa 4** — Criar `.env.example` na raiz consolidado
- [ ] **Etapa 5** — Criar `.github/workflows/docker.yml`
- [ ] **Etapa 6** — Configurar secrets no GitHub
- [ ] Testar build local: `docker compose up --build`
- [ ] Testar health check do backend: `curl http://localhost:3000/health`
- [ ] Testar acesso ao admin: `http://localhost:3001`
