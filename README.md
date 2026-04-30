# OX Field Services 🏗️

Ecossistema completo para serviços de campo com escrow, matching de trabalhadores e gestão de projetos.

## Estrutura do Monorepo

```
ox-field-services/
  ├── ox-backend/        # NestJS API (REST + Swagger)
  ├── ox-admin/          # React Admin Panel (Next.js)
  ├── ox-app-client/     # Flutter App — Cliente
  └── ox-app-worker/     # Flutter App — Trabalhador
```

## Tecnologias

| Camada | Stack |
|--------|-------|
| **Backend** | NestJS, Prisma, PostgreSQL (Supabase), Redis, Stripe |
| **Admin Web** | Next.js, React Query, TailwindCSS |
| **App Cliente** | Flutter, Riverpod, GoRouter |
| **App Worker** | Flutter, Riverpod, GoRouter |
| **Infra** | Railway, Vercel, GitHub Actions |

## Fases do Projeto

Consulte o arquivo [`ox-passo-a-passo.md`](./ox-passo-a-passo.md) para o roadmap completo.
