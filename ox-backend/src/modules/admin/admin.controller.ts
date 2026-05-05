import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { AdminService } from './admin.service';
import { LookupOrCreateClientDto } from './dto/lookup-or-create-client.dto';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Post('clients/lookup-or-create')
  @Roles('admin')
  @ApiOperation({ summary: 'Buscar ou criar cliente por email (apenas admin)' })
  lookupOrCreateClient(@Body() dto: LookupOrCreateClientDto) {
    return this.adminService.lookupOrCreateClient(dto);
  }
}
