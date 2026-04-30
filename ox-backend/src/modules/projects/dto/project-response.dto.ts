import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class PhaseResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  order: number;

  @ApiProperty()
  amount: number;
}

class ContractResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  workerId: string;

  @ApiProperty()
  totalAmount: number;

  @ApiPropertyOptional()
  signedAt?: string;
}

export class ProjectResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  clientId: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  budget: number;

  @ApiProperty()
  location: string;

  @ApiPropertyOptional()
  deadline?: string;

  @ApiProperty()
  createdAt: string;

  @ApiPropertyOptional({ type: [PhaseResponseDto] })
  phases?: PhaseResponseDto[];

  @ApiPropertyOptional({ type: ContractResponseDto })
  contract?: ContractResponseDto;

  @ApiPropertyOptional({ description: 'Eventos disponíveis para transição' })
  availableEvents?: string[];
}
