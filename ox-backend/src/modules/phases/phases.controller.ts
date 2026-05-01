import {
  Controller,
  Get,
  Patch,
  Post,
  Delete,
  Param,
  Body,
  Req,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseUUIDPipe,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { PhasesService } from './phases.service';
import { EvidenceService } from './evidence.service';
import { UpdatePhaseStatusDto } from './dto/update-phase-status.dto';
import { ValidatePhaseDto } from './dto/validate-phase.dto';

@ApiTags('Phases')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller()
export class PhasesController {
  constructor(
    private readonly phasesService: PhasesService,
    private readonly evidenceService: EvidenceService,
  ) {}

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

  @Post('phases/:id/validate')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Validar (aprovar/rejeitar) uma fase — client ou admin' })
  validate(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: ValidatePhaseDto,
  ) {
    return this.phasesService.validatePhase(id, dto.approved, req.user.id);
  }

  // ─── Evidências ────────────────────────────────────────

  @Post('phases/:id/evidence')
  @Roles('worker')
  @ApiOperation({ summary: 'Upload de evidência para uma fase (worker)' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
    },
  })
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: 50 * 1024 * 1024 } }))
  uploadEvidence(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.evidenceService.upload(id, file, req.user.id);
  }

  @Get('phases/:id/evidence')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Listar evidências de uma fase' })
  listEvidence(@Param('id', ParseUUIDPipe) id: string) {
    return this.evidenceService.findByPhase(id);
  }

  @Delete('evidence/:evidenceId')
  @Roles('worker', 'admin')
  @ApiOperation({ summary: 'Remover uma evidência' })
  removeEvidence(
    @Param('evidenceId', ParseUUIDPipe) evidenceId: string,
    @Req() req: any,
  ) {
    return this.evidenceService.remove(evidenceId, req.user.id);
  }
}
