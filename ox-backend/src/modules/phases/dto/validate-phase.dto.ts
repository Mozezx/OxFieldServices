import { IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ValidatePhaseDto {
  @ApiProperty({ description: 'true = aprovado, false = rejeitado' })
  @IsBoolean()
  approved: boolean;
}
