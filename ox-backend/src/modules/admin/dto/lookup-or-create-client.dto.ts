import { IsBoolean, IsEmail, IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class LookupOrCreateClientDto {
  @ApiPropertyOptional({ description: 'E-mail do cliente' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ description: 'Nome do cliente (usado na criação)' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: 'Telefone do cliente' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ description: 'Criar cliente anônimo sem e-mail (dados preenchidos pelo app)' })
  @IsOptional()
  @IsBoolean()
  unregistered?: boolean;
}
