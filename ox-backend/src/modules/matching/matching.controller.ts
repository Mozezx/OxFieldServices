import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { MatchingService } from './matching.service';

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
      'Retorna até 5 workers disponíveis, certificados Shelter e com rating ≥ 3.5, ordenados por rating. O projeto deve estar em status "matched".',
  })
  findCandidates(@Param('projectId') projectId: string) {
    return this.matchingService.findCandidates(projectId);
  }
}
