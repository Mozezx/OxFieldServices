import { Module } from '@nestjs/common';
import { PhasesController } from './phases.controller';
import { PhasesService } from './phases.service';
import { EvidenceService } from './evidence.service';
import { PhaseValidatedHandler } from '../../common/events/phase-validated.handler';

@Module({
  imports: [],
  controllers: [PhasesController],
  providers: [PhasesService, EvidenceService, PhaseValidatedHandler],
  exports: [PhasesService, EvidenceService],
})
export class PhasesModule {}
