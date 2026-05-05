import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RedeemInviteDto {
  @ApiProperty({ description: 'Token plaintext recebido no link de convite' })
  @IsString()
  token: string;
}
