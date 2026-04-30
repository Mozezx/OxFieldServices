import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AuthService } from './auth.service';
import { SyncProfileDto } from './dto/sync-profile.dto';

@ApiTags('auth')
@ApiBearerAuth()
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('sync')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Cria ou retorna o perfil após signup no Supabase' })
  syncProfile(@Req() req: any, @Body() dto: SyncProfileDto) {
    return this.authService.syncProfile(req.user.authId, req.user.email, dto.name, dto.role);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Retorna o perfil do usuário autenticado' })
  me(@Req() req: any) {
    return req.user;
  }
}
