import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { SkillsService } from './skills.service';
import { CreateSkillDto } from './dto/create-skill.dto';

@ApiTags('skills')
@Controller('skills')
export class SkillsController {
  constructor(private skillsService: SkillsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar skills predefinidas' })
  findAll() {
    return this.skillsService.findAll();
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Criar skill predefinida (admin)' })
  create(@Body() dto: CreateSkillDto) {
    return this.skillsService.create(dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @HttpCode(204)
  @ApiOperation({ summary: 'Remover skill predefinida (admin)' })
  remove(@Param('id') id: string) {
    return this.skillsService.remove(id);
  }
}
