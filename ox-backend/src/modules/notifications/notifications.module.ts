import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from '../../prisma/prisma.module';
import { NotificationsListeners } from './notifications.listeners';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [ConfigModule, PrismaModule],
  providers: [NotificationsService, NotificationsListeners],
  exports: [NotificationsService],
})
export class NotificationsModule {}
