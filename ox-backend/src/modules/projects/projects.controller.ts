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
import { ProjectStatus } from '@prisma/client';

@ApiTags('Projects')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Post()
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Criar um novo projeto' })
  create(@Req() req: any, @Body() dto: CreateProjectDto) {
    return this.projectsService.create(req.user.id, dto);
  }

  @Get()
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Listar projetos' })
  @ApiQuery({ name: 'status', required: false, enum: ProjectStatus })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  findAll(
    @Req() req: any,
    @Query('status') status?: ProjectStatus,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    const params: any = { skip: skip ? parseInt(skip, 10) : undefined, take: take ? parseInt(take, 10) : undefined };

    // Filtro por role: client vê seus projetos, admin vê tudo
    if (req.user.role === 'client') {
      params.clientId = req.user.id;
    }
    if (status) params.status = status;

    return this.projectsService.findAll(params);
  }

  @Get(':id')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Obter detalhes de um projeto' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.projectsService.findOne(id);
  }

  @Patch(':id')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Atualizar dados do projeto' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdateProjectDto,
  ) {
    return this.projectsService.update(id, req.user.id, dto);
  }

  @Patch(':id/status')
  @Roles('client', 'worker', 'admin')
  @ApiOperation({ summary: 'Atualizar status do projeto (state machine)' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdateStatusDto,
  ) {
    return this.projectsService.updateStatus(id, req.user.id, dto);
  }

  @Delete(':id')
  @Roles('client', 'admin')
  @ApiOperation({ summary: 'Remover projeto (apenas draft)' })
  remove(@Param('id', ParseUUIDPipe) id: string, @Req() req: any) {
    return this.projectsService.remove(id, req.user.id);
  }
}
