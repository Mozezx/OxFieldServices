import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { ContractsService } from './contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';

@ApiTags('contracts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('contracts')
export class ContractsController {
  constructor(private contractsService: ContractsService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Criar contrato vinculando projeto a worker (admin)' })
  create(@Body() dto: CreateContractDto) {
    return this.contractsService.create(dto);
  }

  @Post(':id/sign')
  @UseGuards(RolesGuard)
  @Roles('worker')
  @ApiOperation({ summary: 'Assinar contrato — worker aceita o job' })
  sign(@Param('id') id: string, @Req() req: any) {
    return this.contractsService.sign(id, req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalhes do contrato com escrow e pagamentos' })
  findOne(@Param('id') id: string) {
    return this.contractsService.findOne(id);
  }

  @Get('project/:projectId')
  @ApiOperation({ summary: 'Buscar contrato pelo ID do projeto' })
  findByProject(@Param('projectId') projectId: string) {
    return this.contractsService.findByProject(projectId);
  }
}
