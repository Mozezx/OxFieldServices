import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { WorkersService } from './workers.service';
import { UpdateWorkerDto } from './dto/update-worker.dto';

@ApiTags('workers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('workers')
export class WorkersController {
  constructor(private workersService: WorkersService) {}

  @Get('me')
  @UseGuards(RolesGuard)
  @Roles('worker')
  @ApiOperation({ summary: 'Ver meu perfil de worker' })
  findMe(@Req() req: any) {
    return this.workersService.findMe(req.user.id);
  }

  @Patch('me')
  @UseGuards(RolesGuard)
  @Roles('worker')
  @ApiOperation({ summary: 'Atualizar meu perfil (skills, disponibilidade, certificação)' })
  updateMe(@Req() req: any, @Body() dto: UpdateWorkerDto) {
    return this.workersService.updateMe(req.user.id, dto);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Listar todos os workers (admin)' })
  @ApiQuery({ name: 'available', required: false, type: Boolean })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  findAll(
    @Query('available') available?: string,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    return this.workersService.findAll({
      available: available !== undefined ? available === 'true' : undefined,
      skip: skip ? parseInt(skip) : undefined,
      take: take ? parseInt(take) : undefined,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Ver perfil de um worker por ID' })
  findOne(@Param('id') id: string) {
    return this.workersService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Atualizar worker por ID (admin)' })
  updateById(@Param('id') id: string, @Body() dto: UpdateWorkerDto) {
    return this.workersService.updateById(id, dto);
  }
}
