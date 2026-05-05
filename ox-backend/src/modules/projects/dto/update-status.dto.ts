import { IsString, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateStatusDto {
  @ApiProperty({
    description: 'Evento de transição (ex: READY, PAY, START, COMPLETE, CONFIRM)',
    example: 'READY',
  })
  @IsString()
  event: string;
}
