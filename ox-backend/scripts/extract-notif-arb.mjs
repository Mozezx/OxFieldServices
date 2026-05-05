import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');

const locales = [
  ['pt', '../ox-app-client/lib/l10n/app_pt.arb'],
  ['en', '../ox-app-client/lib/l10n/app_en.arb'],
  ['es', '../ox-app-client/lib/l10n/app_es.arb'],
  ['nl', '../ox-app-client/lib/l10n/app_nl.arb'],
];

function extractNotifKeys(arbPath) {
  const t = fs.readFileSync(path.join(root, arbPath), 'utf8');
  const o = {};
  const re = /"(notif[a-zA-Z0-9_]+)"\s*:\s*"((?:[^"\\]|\\.)*)"/g;
  let m;
  while ((m = re.exec(t))) {
    o[m[1]] = JSON.parse(`"${m[2]}"`);
  }
  return o;
}

const workerPtPath = path.join(root, '../ox-app-worker/lib/l10n/app_pt.arb');
const workerEnPath = path.join(root, '../ox-app-worker/lib/l10n/app_en.arb');
const workerEsPath = path.join(root, '../ox-app-worker/lib/l10n/app_es.arb');
const workerNlPath = path.join(root, '../ox-app-worker/lib/l10n/app_nl.arb');

function mergeWorkerExtras(locale, bundle) {
  const map = {
    pt: workerPtPath,
    en: workerEnPath,
    es: workerEsPath,
    nl: workerNlPath,
  };
  const p = map[locale];
  if (!fs.existsSync(p)) return bundle;
  const t = fs.readFileSync(p, 'utf8');
  const extraKeys = [
    'notifContractSignedAdminTitle',
    'notifContractSignedAdminBody',
    'notifPaymentFailedAdminTitle',
    'notifPaymentFailedAdminBody',
  ];
  for (const k of extraKeys) {
    const re = new RegExp(`"${k}"\\s*:\\s*"((?:[^"\\\\]|\\\\.)*)"`);
    const m = t.match(re);
    if (m) bundle[k] = JSON.parse(`"${m[1]}"`);
  }
  return bundle;
}

const extras = {
  pt: {
    notifProjectCreatedAdminRegisteredBody:
      'Obra "{projectTitle}" registada para {clientName}.',
    notifInviteRedeemedClientTitle: 'Obra adicionada à sua conta',
    notifInviteRedeemedClientBody:
      'Pode acompanhar as fases e finalizar o pagamento de "{projectTitle}".',
    notifInviteRedeemedAdminTitle: 'Convite resgatado',
    notifInviteRedeemedAdminBody:
      '{clientName} aceitou o convite para a obra "{projectTitle}".',
  },
  en: {
    notifProjectCreatedAdminRegisteredBody:
      'Project "{projectTitle}" registered for {clientName}.',
    notifInviteRedeemedClientTitle: 'Project added to your account',
    notifInviteRedeemedClientBody:
      'You can track phases and complete payment for "{projectTitle}".',
    notifInviteRedeemedAdminTitle: 'Invite redeemed',
    notifInviteRedeemedAdminBody:
      '{clientName} accepted the invite for project "{projectTitle}".',
  },
  es: {
    notifProjectCreatedAdminRegisteredBody:
      'Obra "{projectTitle}" registrada para {clientName}.',
    notifInviteRedeemedClientTitle: 'Obra añadida a tu cuenta',
    notifInviteRedeemedClientBody:
      'Puedes seguir las fases y completar el pago de "{projectTitle}".',
    notifInviteRedeemedAdminTitle: 'Invitación canjeada',
    notifInviteRedeemedAdminBody:
      '{clientName} aceptó la invitación para la obra "{projectTitle}".',
  },
  nl: {
    notifProjectCreatedAdminRegisteredBody:
      'Project "{projectTitle}" geregistreerd voor {clientName}.',
    notifInviteRedeemedClientTitle: 'Project toegevoegd aan je account',
    notifInviteRedeemedClientBody:
      'Je kunt de fases volgen en de betaling voor "{projectTitle}" afronden.',
    notifInviteRedeemedAdminTitle: 'Uitnodiging ingewisseld',
    notifInviteRedeemedAdminBody:
      '{clientName} heeft de uitnodiging voor project "{projectTitle}" geaccepteerd.',
  },
};

const outDir = path.join(root, 'src/modules/notifications/i18n');
fs.mkdirSync(outDir, { recursive: true });

for (const [loc, arbRel] of locales) {
  let bundle = extractNotifKeys(arbRel);
  bundle = mergeWorkerExtras(loc, bundle);
  Object.assign(bundle, extras[loc]);
  fs.writeFileSync(
    path.join(outDir, `${loc}.json`),
    JSON.stringify(bundle, null, 2),
    'utf8',
  );
  console.log(loc, Object.keys(bundle).length, 'keys');
}
