import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateSkillDto } from './dto/create-skill.dto';

@Injectable()
export class SkillsService {
  constructor(private prisma: PrismaService) {}

  findAll() {
    return this.prisma.skill.findMany({ orderBy: { label: 'asc' } });
  }

  async create(dto: CreateSkillDto) {
    const name = dto.name.toLowerCase().trim();
    const existing = await this.prisma.skill.findUnique({ where: { name } });
    if (existing) throw new ConflictException(`Skill '${name}' já existe`);
    return this.prisma.skill.create({ data: { name, label: dto.label.trim() } });
  }

  async remove(id: string) {
    const skill = await this.prisma.skill.findUnique({ where: { id } });
    if (!skill) throw new NotFoundException('Skill não encontrada');
    await this.prisma.skill.delete({ where: { id } });
  }
}
