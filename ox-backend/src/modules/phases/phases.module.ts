import { Module } from '@nestjs/common';
import { PhasesController } from './phases.controller';
import { PhasesService } from './phases.service';
import { EvidenceService } from './evidence.service';
import { PhaseValidatedHandler } from '../../common/events/phase-validated.handler';
import { PaymentsModule } from '../payments/payments.module';

@Module({
  imports: [PaymentsModule],
  controllers: [PhasesController],
  providers: [PhasesService, EvidenceService, PhaseValidatedHandler],
  exports: [PhasesService, EvidenceService],
})
export class PhasesModule {}
