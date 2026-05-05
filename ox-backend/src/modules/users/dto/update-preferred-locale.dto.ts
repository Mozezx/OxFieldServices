import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsString } from 'class-validator';

export const PREFERRED_LOCALES = ['pt', 'en', 'es', 'nl'] as const;
export type PreferredLocale = (typeof PREFERRED_LOCALES)[number];

export class UpdatePreferredLocaleDto {
  @ApiProperty({ enum: PREFERRED_LOCALES, example: 'pt' })
  @IsString()
  @IsIn([...PREFERRED_LOCALES])
  preferredLocale: PreferredLocale;
}
