import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, ValidateIf } from 'class-validator';

export class UpdateAvatarUrlDto {
  @ApiPropertyOptional({
    nullable: true,
    description:
      'URL pública do objeto no bucket Supabase (avatars/{authId}/...) ou null para remover',
  })
  @IsOptional()
  @ValidateIf((_, v) => v != null)
  @IsString()
  @MaxLength(2048)
  avatarUrl?: string | null;
}
