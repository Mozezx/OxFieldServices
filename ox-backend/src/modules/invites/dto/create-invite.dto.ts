import { IsOptional, IsNumber, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class CreateInviteDto {
  /** Validade em dias a partir de agora. Padrão: 14 */
  @ApiPropertyOptional({ description: 'Validade em dias (padrão 14)', default: 14 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  expiresInDays?: number;
}
