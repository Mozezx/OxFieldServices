import { IsString, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateStatusDto {
  @ApiProperty({
    description: 'Evento de transição',
    example: 'SUBMIT',
  })
  @IsString()
  event: string;
}
