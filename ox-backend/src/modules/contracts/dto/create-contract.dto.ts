import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class CreateContractDto {
  @ApiProperty({ description: 'ID do projeto' })
  @IsUUID()
  projectId: string;

  @ApiProperty({ description: 'ID do worker designado' })
  @IsUUID()
  workerId: string;
}
