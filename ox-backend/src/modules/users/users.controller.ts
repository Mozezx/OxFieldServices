import { Body, Controller, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from './users.service';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RevokeDeviceTokenDto } from './dto/revoke-device-token.dto';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('device-tokens')
  @ApiOperation({ summary: 'Registrar token FCM por plataforma (multi-dispositivo)' })
  registerDeviceToken(@Req() req: any, @Body() dto: RegisterDeviceTokenDto) {
    return this.usersService.registerDeviceToken(
      req.user.id,
      dto.token,
      dto.platform,
    );
  }

  @Post('device-tokens/revoke')
  @ApiOperation({ summary: 'Remover token do dispositivo (logout neste aparelho)' })
  revokeDeviceToken(@Req() req: any, @Body() dto: RevokeDeviceTokenDto) {
    return this.usersService.removeDeviceToken(req.user.id, dto.token);
  }

  @Patch('fcm-token')
  @ApiOperation({
    summary:
      'Legado: registrar token FCM (equivale a device-tokens com plataforma android)',
  })
  updateFcmToken(@Req() req: any, @Body() dto: UpdateFcmTokenDto) {
    return this.usersService.updateFcmToken(req.user.id, dto.fcmToken ?? null);
  }
}
