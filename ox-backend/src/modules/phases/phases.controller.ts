import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Req,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { PhasesService } from './phases.service';
import { UpdatePhaseStatusDto } from './dto/update-phase-status.dto';

@ApiTags('Phases')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller()
export class PhasesController {
  constructor(private readonly phasesService: PhasesService) {}

  @Get('projects/:projectId/phases')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Listar fases de um projeto' })
  findByProject(@Param('projectId', ParseUUIDPipe) projectId: string) {
    return this.phasesService.findByProject(projectId);
  }

  @Get('phases/:id')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Obter detalhes de uma fase' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.phasesService.findOne(id);
  }

  @Patch('phases/:id/status')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Atualizar status de uma fase' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdatePhaseStatusDto,
  ) {
    return this.phasesService.updateStatus(id, req.user.id, dto);
  }
}
