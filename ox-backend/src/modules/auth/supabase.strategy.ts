import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../prisma/prisma.service';

interface SupabaseJwtPayload {
  sub: string;
  email: string;
  iat: number;
  exp: number;
}

@Injectable()
export class SupabaseStrategy extends PassportStrategy(Strategy, 'supabase') {
  constructor(private prisma: PrismaService) {
    const secret = process.env.SUPABASE_JWT_SECRET;
    if (!secret) throw new Error('SUPABASE_JWT_SECRET não definido no .env');
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: secret,
    });
  }

  async validate(payload: SupabaseJwtPayload) {
    const user = await this.prisma.user.findUnique({
      where: { authId: payload.sub },
    });

    if (!user) {
      throw new UnauthorizedException('Perfil não encontrado. Chame POST /auth/sync primeiro.');
    }

    return user;
  }
}
