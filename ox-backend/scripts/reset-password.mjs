// Script one-shot: reseta senha de um usuário direto na auth.users do Supabase
// usando bcrypt + pgcrypto. Mais confiável que a admin API quando há issues de
// JWT secret mismatch.
//
// Uso: node scripts/reset-password.mjs <email> <novaSenha>
import 'dotenv/config';
import pg from 'pg';

const [, , email, newPassword] = process.argv;

if (!email || !newPassword) {
  console.error('Uso: node scripts/reset-password.mjs <email> <novaSenha>');
  process.exit(1);
}

const dbUrl = process.env.DATABASE_URL;
if (!dbUrl) {
  console.error('DATABASE_URL ausente no .env');
  process.exit(1);
}

const client = new pg.Client({ connectionString: dbUrl });

async function main() {
  await client.connect();

  const found = await client.query(
    'SELECT id, email FROM auth.users WHERE lower(email) = lower($1)',
    [email],
  );

  if (found.rowCount === 0) {
    console.error(`Usuário com email "${email}" não encontrado em auth.users.`);
    process.exit(1);
  }

  const { id } = found.rows[0];

  // Supabase armazena senha em auth.users.encrypted_password como bcrypt.
  // gen_salt('bf') gera um salt bcrypt, crypt() aplica o hash.
  await client.query(
    `UPDATE auth.users
     SET encrypted_password = crypt($1, gen_salt('bf')),
         updated_at = now()
     WHERE id = $2`,
    [newPassword, id],
  );

  console.log(`Senha redefinida com sucesso para ${email} (id: ${id})`);
}

main()
  .catch((err) => {
    console.error('Erro:', err);
    process.exitCode = 1;
  })
  .finally(() => client.end());
