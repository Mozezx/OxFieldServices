import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateFcmTokenDto {
  @ApiProperty({
    description: 'Token FCM do dispositivo móvel',
    example: 'fcm-device-token-123',
  })
  @IsString()
  @MaxLength(4096)
  fcmToken: string;

  @ApiPropertyOptional({
    description: 'Permite remover o token atual quando necessário',
    example: null,
    nullable: true,
  })
  @IsOptional()
  @IsString()
  @MaxLength(4096)
  previousToken?: string;
}
