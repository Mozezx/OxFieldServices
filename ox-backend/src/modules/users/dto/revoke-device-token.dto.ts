import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class RevokeDeviceTokenDto {
  @ApiProperty()
  @IsString()
  @MinLength(10)
  token: string;
}
