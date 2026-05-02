import { ApiProperty } from '@nestjs/swagger';
import { DevicePlatform } from '@prisma/client';
import { IsEnum, IsString, MinLength } from 'class-validator';

export class RegisterDeviceTokenDto {
  @ApiProperty()
  @IsString()
  @MinLength(10)
  token: string;

  @ApiProperty({ enum: DevicePlatform })
  @IsEnum(DevicePlatform)
  platform: DevicePlatform;
}
