import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from '../../prisma/prisma.module';
import { NotificationsController } from './notifications.controller';
import { NotificationsListeners } from './notifications.listeners';
import { NotificationCopyService } from './notification-copy.service';
import { AppSyncService } from './app-sync.service';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [ConfigModule, PrismaModule],
  controllers: [NotificationsController],
  providers: [
    NotificationCopyService,
    AppSyncService,
    NotificationsService,
    NotificationsListeners,
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
