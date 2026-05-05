-- Migration: remover in_validation do enum ProjectStatus e criar tabela ProjectInvite
--
-- Motivo: o admin agora cria a obra após a visita presencial, então não há
-- mais etapa de validação. Projetos antigos em `in_validation` são migrados
-- automaticamente para `matched` (o passo seguinte do antigo fluxo).

-- 1) Migrar dados existentes ----------------------------------------------------

UPDATE "Project"
   SET "status" = 'matched'
 WHERE "status" = 'in_validation';

-- 2) Recriar o enum ProjectStatus sem 'in_validation' ---------------------------

ALTER TYPE "ProjectStatus" RENAME TO "ProjectStatus_old";

CREATE TYPE "ProjectStatus" AS ENUM (
  'draft',
  'matched',
  'contract_signed',
  'active_escrow',
  'in_execution',
  'closing',
  'closed',
  'rejected'
);

ALTER TABLE "Project"
  ALTER COLUMN "status" DROP DEFAULT,
  ALTER COLUMN "status" TYPE "ProjectStatus"
    USING ("status"::text::"ProjectStatus"),
  ALTER COLUMN "status" SET DEFAULT 'draft';

DROP TYPE "ProjectStatus_old";

-- 3) Tabela de convites para o cliente acessar a obra ---------------------------

CREATE TABLE "ProjectInvite" (
  "id"          TEXT      NOT NULL,
  "projectId"   TEXT      NOT NULL,
  "clientId"    TEXT      NOT NULL,
  "tokenHash"   TEXT      NOT NULL,
  "expiresAt"   TIMESTAMP(3) NOT NULL,
  "usedAt"      TIMESTAMP(3),
  "revokedAt"   TIMESTAMP(3),
  "createdById" TEXT      NOT NULL,
  "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "ProjectInvite_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ProjectInvite_tokenHash_key" ON "ProjectInvite"("tokenHash");
CREATE INDEX "ProjectInvite_projectId_idx" ON "ProjectInvite"("projectId");
CREATE INDEX "ProjectInvite_clientId_idx"  ON "ProjectInvite"("clientId");

ALTER TABLE "ProjectInvite"
  ADD CONSTRAINT "ProjectInvite_projectId_fkey"
  FOREIGN KEY ("projectId") REFERENCES "Project"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "ProjectInvite"
  ADD CONSTRAINT "ProjectInvite_clientId_fkey"
  FOREIGN KEY ("clientId") REFERENCES "User"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- 4) Novo tipo de notificação para resgate de convite ---------------------------

ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'invite_redeemed';
