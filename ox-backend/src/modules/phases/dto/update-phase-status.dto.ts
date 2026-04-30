import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { PhaseStatus } from '@prisma/client';

export class UpdatePhaseStatusDto {
  @ApiProperty({ enum: PhaseStatus, description: 'Novo status da fase' })
  @IsEnum(PhaseStatus)
  status: PhaseStatus;
}
