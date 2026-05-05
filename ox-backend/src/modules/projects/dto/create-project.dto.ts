import { IsString, IsOptional, IsNumber, IsDateString, IsArray, ValidateNested, Min, IsUUID, IsEmail } from 'class-validator';
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

  @ApiPropertyOptional({ description: 'UUID do cliente (apenas admin)' })
  @IsOptional()
  @IsUUID()
  clientId?: string;

  @ApiPropertyOptional({ description: 'E-mail do cliente (apenas admin; alternativa a clientId)' })
  @IsOptional()
  @IsEmail()
  clientEmail?: string;

  @ApiPropertyOptional({
    description:
      'Publica a obra direto em "matched" (pronta para matching). Apenas admin. Se false/omitido, fica em "draft" e pode ser publicada depois pelo evento READY.',
  })
  @IsOptional()
  submit?: boolean;

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
