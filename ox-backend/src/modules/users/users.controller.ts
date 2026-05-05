import {
  Body,
  Controller,
  ForbiddenException,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from './users.service';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RevokeDeviceTokenDto } from './dto/revoke-device-token.dto';
import { UpdatePreferredLocaleDto } from './dto/update-preferred-locale.dto';
import { UpdateAvatarUrlDto } from './dto/update-avatar-url.dto';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /** JWT pode existir antes de POST /auth/sync — neste caso não há `id` de app. */
  private appUserId(req: { user?: { id?: string } }): string {
    const id = req.user?.id;
    if (!id) {
      throw new ForbiddenException(
        'Conclua o registo na API (POST /auth/sync) antes de registar notificações push.',
      );
    }
    return id;
  }

  @Post('device-tokens')
  @ApiOperation({ summary: 'Registrar token FCM por plataforma (multi-dispositivo)' })
  registerDeviceToken(@Req() req: any, @Body() dto: RegisterDeviceTokenDto) {
    return this.usersService.registerDeviceToken(
      this.appUserId(req),
      dto.token,
      dto.platform,
    );
  }

  @Post('device-tokens/revoke')
  @ApiOperation({ summary: 'Remover token do dispositivo (logout neste aparelho)' })
  revokeDeviceToken(@Req() req: any, @Body() dto: RevokeDeviceTokenDto) {
    return this.usersService.removeDeviceToken(this.appUserId(req), dto.token);
  }

  @Patch('fcm-token')
  @ApiOperation({
    summary:
      'Legado: registrar token FCM (equivale a device-tokens com plataforma android)',
  })
  updateFcmToken(@Req() req: any, @Body() dto: UpdateFcmTokenDto) {
    return this.usersService.updateFcmToken(this.appUserId(req), dto.fcmToken ?? null);
  }

  @Patch('preferred-locale')
  @ApiOperation({
    summary:
      'Idioma preferido para notificações push e texto persistido (pt, en, es, nl)',
  })
  updatePreferredLocale(@Req() req: any, @Body() dto: UpdatePreferredLocaleDto) {
    return this.usersService.updatePreferredLocale(
      this.appUserId(req),
      dto.preferredLocale,
    );
  }

  @Patch('avatar-url')
  @ApiOperation({
    summary:
      'Atualizar URL da foto de perfil (URL pública Supabase Storage em avatars/{authId}/)',
  })
  updateAvatarUrl(@Req() req: any, @Body() dto: UpdateAvatarUrlDto) {
    const authId = req.user?.authId as string | undefined;
    if (!authId || req.user?._unsynced) {
      throw new ForbiddenException(
        'Conclua o registo na API (POST /auth/sync) antes de atualizar o avatar.',
      );
    }
    return this.usersService.updateAvatarUrl(this.appUserId(req), authId, dto.avatarUrl);
  }
}
