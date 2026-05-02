import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MinLength } from 'class-validator';

export class CreateSkillDto {
  @ApiProperty({ example: 'eletrica' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'Elétrica' })
  @IsString()
  @MinLength(1)
  label: string;
}
