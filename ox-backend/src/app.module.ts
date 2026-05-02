import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { PhasesModule } from './modules/phases/phases.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ContractsModule } from './modules/contracts/contracts.module';
import { WorkersModule } from './modules/workers/workers.module';
import { MatchingModule } from './modules/matching/matching.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { UsersModule } from './modules/users/users.module';
import { SkillsModule } from './modules/skills/skills.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    EventEmitterModule.forRoot(),
    PrismaModule,
    AuthModule,
    ProjectsModule,
    PhasesModule,
    PaymentsModule,
    ContractsModule,
    WorkersModule,
    MatchingModule,
    NotificationsModule,
    UsersModule,
    SkillsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
