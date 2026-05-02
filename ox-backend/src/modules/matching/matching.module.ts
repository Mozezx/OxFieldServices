import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { ContractsModule } from '../contracts/contracts.module';
import { MatchingController } from './matching.controller';
import { MatchingService } from './matching.service';

@Module({
  imports: [PrismaModule, ContractsModule],
  controllers: [MatchingController],
  providers: [MatchingService],
})
export class MatchingModule {}
