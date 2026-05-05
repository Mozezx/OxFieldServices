import {
  Controller,
  Get,
  Post,
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
import { Public } from '../../common/decorators/public.decorator';
import { InvitesService } from './invites.service';
import { RedeemInviteDto } from './dto/redeem-invite.dto';

@ApiTags('Invites')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('invites')
export class InvitesController {
  constructor(private readonly invitesService: InvitesService) {}

  private userKey(req: { user?: { id?: string; authId?: string } }): string {
    return String(req.user?.id ?? req.user?.authId ?? '');
  }

  @Get('preview')
  @Public()
  @ApiOperation({ summary: 'Prévia pública do convite (sem dados sensíveis)' })
  @ApiQuery({ name: 'token', required: true })
  preview(@Query('token') token: string) {
    return this.invitesService.preview(token);
  }

  @Post('redeem')
  @Roles('client')
  @ApiOperation({ summary: 'Resgatar convite e vincular projeto à conta' })
  redeem(@Req() req: any, @Body() dto: RedeemInviteDto) {
    return this.invitesService.redeem(this.userKey(req), dto);
  }

  @Delete(':id')
  @Roles('admin')
  @ApiOperation({ summary: 'Revogar convite' })
  revoke(@Param('id', ParseUUIDPipe) id: string) {
    return this.invitesService.revoke(id);
  }
}
