-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM (
  'user_welcome',
  'project_created',
  'project_in_validation',
  'project_matched',
  'project_activated',
  'project_closing',
  'project_closed',
  'project_rejected',
  'phase_started',
  'phase_evidence_uploaded',
  'phase_under_review',
  'phase_validated',
  'phase_rejected',
  'contract_created',
  'contract_signed',
  'escrow_held',
  'escrow_released',
  'escrow_refunded',
  'payment_transferred',
  'payment_failed',
  'worker_invited',
  'worker_assigned',
  'worker_rated'
);

-- CreateEnum
CREATE TYPE "DevicePlatform" AS ENUM ('ios', 'android', 'web');

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "entityType" TEXT,
    "entityId" TEXT,
    "data" JSONB,
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DeviceToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "platform" "DevicePlatform" NOT NULL,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DeviceToken_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Notification_userId_readAt_idx" ON "Notification"("userId", "readAt");

-- CreateIndex
CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "DeviceToken_token_key" ON "DeviceToken"("token");

-- CreateIndex
CREATE INDEX "DeviceToken_userId_idx" ON "DeviceToken"("userId");

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeviceToken" ADD CONSTRAINT "DeviceToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Backfill legacy FCM tokens into DeviceToken (assume mobile android when unknown)
INSERT INTO "DeviceToken" ("id", "userId", "token", "platform", "lastSeen", "createdAt")
SELECT gen_random_uuid()::text, "id", "fcmToken", 'android'::"DevicePlatform", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM "User"
WHERE "fcmToken" IS NOT NULL AND trim("fcmToken") <> '';
