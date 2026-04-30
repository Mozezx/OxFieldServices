import { IsString, IsOptional, IsNumber, IsDateString, IsArray, ValidateNested, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreatePhaseDto {
  @ApiProperty({ description: 'Nome da fase' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'Ordem da fase' })
  @IsNumber()
  @Min(1)
  order: number;

  @ApiProperty({ description: 'Valor da fase' })
  @IsNumber()
  @Min(0)
  amount: number;
}

export class CreateProjectDto {
  @ApiProperty({ description: 'Título do projeto' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Orçamento total' })
  @IsNumber()
  @Min(0)
  budget: number;

  @ApiProperty({ description: 'Localização' })
  @IsString()
  location: string;

  @ApiPropertyOptional({ description: 'Prazo' })
  @IsOptional()
  @IsDateString()
  deadline?: string;

  @ApiPropertyOptional({
    description: 'Fases do projeto',
    type: [CreatePhaseDto],
  })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreatePhaseDto)
  phases?: CreatePhaseDto[];
}
