import {
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { NotificationsQueryDto } from './dto/notifications-query.dto';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar notificações (paginado por cursor)' })
  async list(@Req() req: any, @Query() query: NotificationsQueryDto) {
    return this.notificationsService.listForUser({
      userId: req.user.id,
      cursor: query.cursor,
      limit: query.limit ?? 20,
    });
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Contagem de notificações não lidas' })
  unreadCount(@Req() req: any) {
    return this.notificationsService.unreadCount(req.user.id);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Marcar todas como lidas' })
  markAllRead(@Req() req: any) {
    return this.notificationsService.markAllRead(req.user.id);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Marcar uma notificação como lida' })
  markRead(
    @Req() req: any,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.markRead(req.user.id, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remover uma notificação' })
  remove(
    @Req() req: any,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.deleteOne(req.user.id, id);
  }
}
