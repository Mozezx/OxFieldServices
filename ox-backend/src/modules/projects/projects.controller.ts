import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { ProjectsService } from './projects.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { UpdateStatusDto } from './dto/update-status.dto';
import { RateProjectDto } from './dto/rate-project.dto';
import { InvitesService } from '../invites/invites.service';
import { CreateInviteDto } from '../invites/dto/create-invite.dto';
import { ProjectStatus } from '@prisma/client';

@ApiTags('Projects')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('projects')
export class ProjectsController {
  constructor(
    private readonly projectsService: ProjectsService,
    private readonly invitesService: InvitesService,
  ) {}

  /** id interno Prisma ou, em último caso, authId (Supabase sub). */
  private userKey(req: { user?: { id?: string; authId?: string } }): string {
    return String(req.user?.id ?? req.user?.authId ?? '');
  }

  @Post()
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Criar um novo projeto' })
  create(@Req() req: any, @Body() dto: CreateProjectDto) {
    return this.projectsService.create(this.userKey(req), dto);
  }

  @Get()
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Listar projetos' })
  @ApiQuery({ name: 'status', required: false, enum: ProjectStatus })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  @ApiQuery({
    name: 'workerJobs',
    required: false,
    type: Boolean,
    description:
      'Quando true e role=worker, lista apenas projetos atribuídos ao worker. Padrão para workers.',
  })
  @ApiQuery({
    name: 'noContract',
    required: false,
    type: Boolean,
    description: 'Lista apenas projetos sem contrato (útil para matching).',
  })
  async findAll(
    @Req() req: any,
    @Query('status') status?: ProjectStatus,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('workerJobs') workerJobs?: string,
    @Query('noContract') noContract?: string,
  ) {
    const params: any = {
      skip: skip ? parseInt(skip, 10) : undefined,
      take: take ? parseInt(take, 10) : undefined,
    };

    // Filtro por role:
    //  - client: vê apenas seus próprios projetos
    //  - worker: por padrão, vê apenas projetos onde está atribuído por contrato.
    //    Pode pedir explicitamente noContract=true para ver disponíveis.
    //  - admin: vê tudo
    if (req.user.role === 'client') {
      params.clientId = await this.projectsService.resolveUserKeyToId(this.userKey(req));
    } else if (req.user.role === 'worker') {
      const wantsAvailable = noContract === 'true';
      let workerId: string | undefined = req.user.worker?.id;
      if (!workerId) {
        workerId = await this.projectsService.findWorkerIdForAppUser(req.user.id);
      }
      if (wantsAvailable) {
        params.noContract = true;
      } else if (workerId) {
        params.workerId = workerId;
      } else {
        // Worker sem registo Worker em DB: lista vazia (não expor todos os projetos).
        return { data: [], total: 0, skip: 0, take: 0 };
      }
    }

    if (status) params.status = status;
    // workerJobs hoje é um hint do app; o filtro real já foi aplicado acima
    if (workerJobs === 'true' && req.user.role === 'worker') {
      // noop — o filtro por workerId já foi setado
    }

    return this.projectsService.findAll(params);
  }

  @Get(':id')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Obter detalhes de um projeto' })
  findOne(@Param('id', ParseUUIDPipe) id: string, @Req() req: any) {
    return this.projectsService.findOne(id, this.userKey(req));
  }

  @Patch(':id')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Atualizar dados do projeto' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdateProjectDto,
  ) {
    return this.projectsService.update(id, this.userKey(req), dto);
  }

  @Patch(':id/status')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Atualizar status do projeto (state machine)' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdateStatusDto,
  ) {
    return this.projectsService.updateStatus(id, this.userKey(req), dto);
  }

  @Post(':id/rating')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Avaliar o trabalhador ao final do projeto' })
  rateWorker(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: RateProjectDto,
  ) {
    return this.projectsService.rateWorker(id, this.userKey(req), dto);
  }

  @Delete(':id')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Remover projeto (apenas draft)' })
  remove(@Param('id', ParseUUIDPipe) id: string, @Req() req: any) {
    return this.projectsService.remove(id, this.userKey(req));
  }

  @Post(':id/invites')
  @Roles('admin')
  @ApiOperation({ summary: 'Criar convite para o projeto (admin)' })
  createInvite(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: CreateInviteDto,
  ) {
    const adminId = String(req.user?.id ?? req.user?.authId ?? '');
    return this.invitesService.createForProject(id, adminId, dto);
  }

  @Get(':id/invites')
  @Roles('admin')
  @ApiOperation({ summary: 'Listar convites do projeto (admin)' })
  listInvites(@Param('id', ParseUUIDPipe) id: string) {
    return this.invitesService.findByProject(id);
  }
}
