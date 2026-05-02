import {
  Injectable,
  BadRequestException,
  NotFoundException,
  InternalServerErrorException,
  ForbiddenException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { createClient } from '@supabase/supabase-js';
import { PrismaService } from '../../prisma/prisma.service';

const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'video/mp4',
  'video/quicktime',
];

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB

@Injectable()
export class EvidenceService {
  private supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
  );

  constructor(
    private prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async upload(
    phaseId: string,
    file: Express.Multer.File,
    userId: string,
  ) {
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new BadRequestException(
        'Tipo de arquivo não permitido. Use jpeg, png, webp, mp4 ou mov.',
      );
    }

    if (file.size > MAX_FILE_SIZE) {
      throw new BadRequestException('Arquivo excede o limite de 50 MB.');
    }

    const phase = await this.prisma.projectPhase.findUnique({
      where: { id: phaseId },
      include: {
        project: { select: { status: true } },
      },
    });

    if (!phase) throw new NotFoundException('Fase não encontrada');

    // Só permite upload quando a fase está em progresso ou rejeitada (reenvio)
    if (phase.status !== 'in_progress' && phase.status !== 'rejected') {
      throw new BadRequestException(
        'Upload permitido apenas em fases com status in_progress ou rejected.',
      );
    }

    const ext = file.originalname.split('.').pop();
    const path = `phases/${phaseId}/${Date.now()}.${ext}`;

    const { error } = await this.supabase.storage
      .from('evidences')
      .upload(path, file.buffer, { contentType: file.mimetype, upsert: false });

    if (error) {
      throw new InternalServerErrorException(
        `Falha no upload para o storage: ${error.message}`,
      );
    }

    const { data: { publicUrl } } = this.supabase.storage
      .from('evidences')
      .getPublicUrl(path);

    const evidence = await this.prisma.phaseEvidence.create({
      data: {
        phaseId,
        type: file.mimetype,
        url: publicUrl,
        uploadedBy: userId,
      },
    });

    // Avança a fase para evidence_uploaded automaticamente
    if (phase.status === 'in_progress') {
      await this.prisma.projectPhase.update({
        where: { id: phaseId },
        data: { status: 'evidence_uploaded' },
      });
    }

    this.eventEmitter.emit('phase.evidence_uploaded', { phaseId });

    return evidence;
  }

  async findByPhase(phaseId: string) {
    const phase = await this.prisma.projectPhase.findUnique({
      where: { id: phaseId },
    });

    if (!phase) throw new NotFoundException('Fase não encontrada');

    return this.prisma.phaseEvidence.findMany({
      where: { phaseId },
      orderBy: { uploadedAt: 'desc' },
    });
  }

  async remove(evidenceId: string, userId: string) {
    const evidence = await this.prisma.phaseEvidence.findUnique({
      where: { id: evidenceId },
      include: {
        phase: { select: { status: true } },
        uploader: { select: { role: true } },
      },
    });

    if (!evidence) throw new NotFoundException('Evidência não encontrada');

    if (evidence.uploadedBy !== userId && evidence.uploader.role !== 'admin') {
      throw new ForbiddenException('Sem permissão para remover esta evidência');
    }

    if (
      evidence.phase.status !== 'in_progress' &&
      evidence.phase.status !== 'evidence_uploaded' &&
      evidence.phase.status !== 'rejected'
    ) {
      throw new BadRequestException(
        'Evidências só podem ser removidas antes da revisão.',
      );
    }

    // Extrair path do storage da URL pública
    const url = new URL(evidence.url);
    const storagePath = url.pathname.split('/object/public/evidences/')[1];

    if (storagePath) {
      await this.supabase.storage.from('evidences').remove([storagePath]);
    }

    await this.prisma.phaseEvidence.delete({ where: { id: evidenceId } });

    return { deleted: true };
  }
}
