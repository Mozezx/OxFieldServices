# Setup do Stripe (modo teste)

Passos manuais para colocar o fluxo Stripe end-to-end funcionando em desenvolvimento.

## 1. Conta Stripe e chaves

1. Crie / acesse uma conta em [stripe.com](https://dashboard.stripe.com).
2. Garanta que o toggle no canto superior direito está em **Test mode**.
3. Em [API keys](https://dashboard.stripe.com/test/apikeys) copie:
   - `Secret key` → `STRIPE_SECRET_KEY` no `ox-backend/.env` (formato `sk_test_...`)
   - `Publishable key` → `STRIPE_PUBLISHABLE_KEY` no `ox-backend/.env` (formato `pk_test_...`)

> Os apps Flutter buscam a publishable key automaticamente em `GET /payments/config`, não precisa hardcode.

## 2. Stripe Connect (para o worker receber)

1. Em [Connect → Settings](https://dashboard.stripe.com/test/settings/connect):
   - Habilite **Express accounts**
   - Plataforma: configure Branding (nome, cor, logo) — vai aparecer no onboarding hospedado.
   - Em **Capabilities**, garanta que `transfers` está habilitado.
2. Não é necessário aprovar a plataforma para uso em modo teste.

## 3. Webhook local com Stripe CLI

Instale o [Stripe CLI](https://stripe.com/docs/stripe-cli) e rode em um terminal separado:

```bash
stripe login
stripe listen --forward-to localhost:3000/webhooks/stripe
```

Copie o `whsec_...` exibido no terminal e cole em `ox-backend/.env`:

```
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

Reinicie o backend. Eventos como `payment_intent.succeeded` agora chegam ao backend e disparam o avanço do state machine do projeto.

## 4. Migration do Prisma

Após puxar essas mudanças, gere o client Prisma (ou aplique a migration nova `add_user_stripe_customer`):

```bash
cd ox-backend
npx prisma migrate dev
npx prisma generate
```

## 5. Apps Flutter

Os apps cliente e worker já estão preparados:

- `ox-app-client` usa `flutter_stripe` e busca a publishable key no boot.
- `ox-app-worker` usa `url_launcher` para abrir o onboarding Connect no navegador.

Após `flutter pub get` em ambos, basta rodar normalmente. Lembre que o `MainActivity` do cliente foi alterado para `FlutterFragmentActivity` (necessário para o PaymentSheet).

## 6. Cartões de teste

| Cenário | Número |
| --- | --- |
| Pagamento aprovado | `4242 4242 4242 4242` |
| Pagamento com 3D Secure | `4000 0025 0000 3155` |
| Pagamento recusado | `4000 0000 0000 9995` |

Use qualquer data futura para validade e qualquer CVC.

## 7. Onboarding Connect (worker)

No fluxo de teste, ao abrir o link de onboarding no navegador:

- Use `000000000` ou `000-00-0000` quando pedir SSN/CPF.
- Use `Test bank account` quando pedir conta bancária.
- Endereço pode ser qualquer um válido no país selecionado.

Após concluir, volte ao app — o status atualiza automaticamente quando o app volta ao foreground (lifecycle resumed).

## 8. Fluxo completo de teste

1. Worker abre Perfil → "Configurar agora" → completa onboarding → status `active`.
2. Cliente abre Perfil → "Adicionar cartão" → digita 4242... → cartão salvo.
3. Admin cria projeto, atribui worker → status `contract_signed`.
4. Worker abre app → vê job → "Aceitar Job" → contrato assinado.
5. Cliente abre projeto → "Pagar e Iniciar Projeto" → PaymentSheet → confirma com cartão salvo.
6. Webhook chega → projeto vai para `in_execution`, primeira fase para `in_progress`.
7. Worker abre aba "Em Execução" → vê fase ativa → upload de evidências → "Enviar para Revisão".
8. Cliente valida → split 70/30 transfere para a conta Connect do worker.
