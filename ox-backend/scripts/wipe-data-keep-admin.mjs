/**
 * Apaga todos os dados de negócio e contas (client/worker), mantendo apenas
 * linhas em public."User" com role = admin. Limpa notificações, tokens,
 * skills e auth Supabase para utilizadores que deixam de existir em public."User".
 *
 * Uso (na pasta ox-backend): node scripts/wipe-data-keep-admin.mjs
 * Requer DATABASE_URL no .env (mesmo do Prisma).
 */
import 'dotenv/config';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const adminCount = await prisma.user.count({ where: { role: 'admin' } });
  if (adminCount === 0) {
    console.error(
      'Abortado: não existe nenhum utilizador com role admin em public."User". Crie o admin antes de correr este script.',
    );
    process.exit(1);
  }

  await prisma.$transaction(async (tx) => {
    await tx.payment.deleteMany();
    await tx.escrowTxn.deleteMany();
    await tx.contract.deleteMany();
    await tx.workerRating.deleteMany();
    await tx.phaseEvidence.deleteMany();
    await tx.projectPhase.deleteMany();
    await tx.project.deleteMany();
    await tx.worker.deleteMany();
    await tx.notification.deleteMany();
    await tx.deviceToken.deleteMany();
    await tx.skill.deleteMany();
    await tx.user.updateMany({
      where: { role: 'admin' },
      data: { fcmToken: null, stripeCustomerId: null },
    });
    const deleted = await tx.user.deleteMany({ where: { role: { not: 'admin' } } });
    console.log(`Utilizadores não-admin removidos da app DB: ${deleted.count}`);
  });

  try {
    const r = await prisma.$executeRaw`
      DELETE FROM auth.users a
      WHERE NOT EXISTS (
        SELECT 1 FROM public."User" u WHERE u."authId" = a.id::text
      )
    `;
    console.log(`auth.users: linhas afetadas (delete): ${r}`);
  } catch (e) {
    console.warn(
      'Aviso: não foi possível limpar auth.users (schema auth inexistente ou sem permissão). Apague utilizadores órfãos no Supabase Dashboard se necessário.',
    );
    console.warn(e.message);
  }

  const remaining = await prisma.user.count();
  console.log(`Concluído. Utilizadores restantes em public."User": ${remaining} (esperado: ${adminCount}).`);
}

main()
  .catch((err) => {
    console.error(err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
