-- AlterTable (IF NOT EXISTS: evita P3018 se a coluna já existir no banco)
ALTER TABLE "EscrowTxn" ADD COLUMN IF NOT EXISTS "stripeSourceChargeId" TEXT;
