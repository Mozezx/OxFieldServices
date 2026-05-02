import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { MatchingService } from './matching.service';

class AssignWorkerDto {
  @IsUUID()
  workerId: string;
}

@ApiTags('matching')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Controller('matching')
export class MatchingController {
  constructor(private matchingService: MatchingService) {}

  @Get(':projectId/candidates')
  @ApiOperation({
    summary: 'Buscar candidatos elegíveis para um projeto (admin)',
    description:
      'Retorna até 5 workers disponíveis com rating ≥ 3.5, ordenados por score de compatibilidade.',
  })
  findCandidates(@Param('projectId') projectId: string) {
    return this.matchingService.findCandidates(projectId);
  }

  @Post(':projectId/assign')
  @ApiOperation({
    summary: 'Atribuir worker ao projeto e criar contrato (admin)',
    description:
      'Cria o contrato vinculando o worker ao projeto e transiciona o status para contract_signed.',
  })
  assignWorker(
    @Param('projectId') projectId: string,
    @Body() dto: AssignWorkerDto,
  ) {
    return this.matchingService.assignWorker(projectId, dto.workerId);
  }
}
