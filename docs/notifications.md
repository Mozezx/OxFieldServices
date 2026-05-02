# Notificações OX Field Services

Sistema unificado: **persistência em PostgreSQL** (`Notification`) + **push FCM** (Android, iOS, Web) via `DeviceToken` e, durante a transição, `User.fcmToken` legado.

## Backend (NestJS)

- **Modelos:** [`ox-backend/prisma/schema.prisma`](../ox-backend/prisma/schema.prisma) — `Notification`, `DeviceToken`, enums `NotificationType`, `DevicePlatform`.
- **API:**
  - `GET /notifications?cursor=&limit=` — lista paginada; resposta `{ items, nextCursor }`.
  - `GET /notifications/unread-count` — `{ count }`.
  - `PATCH /notifications/:id/read`, `PATCH /notifications/read-all`.
  - `POST /users/device-tokens` — body `{ token, platform }` (`ios` | `android` | `web`).
  - `POST /users/device-tokens/revoke` — body `{ token }`.
  - `PATCH /users/fcm-token` — legado; grava também em `DeviceToken` como `android`.
- **Eventos de domínio** (`@nestjs/event-emitter`): `user.created`, `project.created`, `project.status_changed`, `phase.*`, `contract.*`, `escrow.held`, `payment.*`, `worker.*`, `worker.rated`, etc. Listeners em [`ox-backend/src/modules/notifications/notifications.listeners.ts`](../ox-backend/src/modules/notifications/notifications.listeners.ts).
- **Variáveis:** [`ox-backend/.env.example`](../ox-backend/.env.example) — `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL` (Admin SDK para enviar FCM).

### Migração

```bash
cd ox-backend
npx prisma migrate deploy
# ou em dev:
npx prisma migrate dev
```

## Apps Flutter (cliente e trabalhador)

- **Opções Firebase:** `lib/firebase_options.dart` — preencher com `flutterfire configure` ou `--dart-define` (`FIREBASE_PROJECT_ID`, `FIREBASE_ANDROID_API_KEY`, etc.).
- **Android:** adicionar `google-services.json` em `android/app/` (Firebase Console).
- **iOS:** `GoogleService-Info.plist` + capabilities Push.
- **Código:** `lib/core/notifications/push_notifications_service.dart` — registro de token, `onMessage`, deep links.
- **Inbox:** `lib/features/notifications/notifications_screen.dart` + `notifications_provider.dart`.

## Admin (Next.js)

- **Env (público):** prefixo `NEXT_PUBLIC_`:
  - `NEXT_PUBLIC_FIREBASE_API_KEY`
  - `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
  - `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
  - `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET`
  - `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`
  - `NEXT_PUBLIC_FIREBASE_APP_ID`
  - `NEXT_PUBLIC_FIREBASE_VAPID_KEY` — Web Push (Console Firebase → Project settings → Cloud Messaging → Web Push certificates).
- **Código:** [`ox-admin/lib/firebase/messaging.ts`](../ox-admin/lib/firebase/messaging.ts), [`ox-admin/components/providers/FcmBootstrap.tsx`](../ox-admin/components/providers/FcmBootstrap.tsx), página [`ox-admin/app/(dashboard)/notifications/page.tsx`](../ox-admin/app/(dashboard)/notifications/page.tsx).
- **Service worker:** [`ox-admin/public/firebase-messaging-sw.js`](../ox-admin/public/firebase-messaging-sw.js) — substituir placeholders pelos mesmos valores do app Web no Firebase (necessário para push em background).

## Catálogo resumido (audiência)

| Evento / tipo | Principais destinatários |
|----------------|---------------------------|
| `user_welcome` | Próprio usuário |
| `project_created` | Cliente + admins |
| `project_*` (status) | Cliente, worker (se houver), admins — exceto `closed` (sem admins) |
| Fases (`phase_*`) | Cliente e/ou worker conforme ação |
| `contract_*`, `escrow_*`, `payment_*` | Cliente, worker, admins conforme regra financeira |
| `worker_invited` / `worker_assigned` | Worker |
| `worker_rated` | Worker |

## Testes rápidos

1. **API:** após login, `GET /notifications` deve retornar `items` (pode ser vazio).
2. **FCM:** Firebase Console → Messaging → **Send test message** com um FCM token registrado (logs ou endpoint device-tokens).
3. **Admin:** abrir o painel, aceitar permissão de notificação do browser; ver token em rede (`POST /users/device-tokens`).
