import { NotificationCopyService } from './notification-copy.service';

describe('NotificationCopyService', () => {
  let svc: NotificationCopyService;

  beforeEach(() => {
    svc = new NotificationCopyService();
  });

  it('normalizes unknown locale to pt', () => {
    expect(svc.normalizeLocale('fr')).toBe('pt');
    expect(svc.normalizeLocale('pt-BR')).toBe('pt');
    expect(svc.normalizeLocale('en')).toBe('en');
  });

  it('formats user_welcome in English', () => {
    const r = svc.format(
      'user_welcome',
      'en',
      {},
      { title: 'fallback', body: 'fallback' },
    );
    expect(r.title).toBe('Welcome to OX Field Service');
    expect(r.body).toContain('account');
  });

  it('formats project_created for admin when createdByAdmin', () => {
    const r = svc.format(
      'project_created',
      'pt',
      {
        variant: 'admin',
        projectTitle: 'Obra A',
        clientName: 'Maria',
        createdByAdmin: true,
      },
      { title: 'x', body: 'y' },
    );
    expect(r.body).toContain('Obra A');
    expect(r.body).toContain('Maria');
  });

  it('formats payment_transferred for worker with amount', () => {
    const r = svc.format(
      'payment_transferred',
      'pt',
      {
        projectTitle: 'P1',
        amount: '100.00',
      },
      { title: 'x', body: 'y' },
    );
    expect(r.body).toContain('100.00');
    expect(r.body).toContain('P1');
  });

  it('falls back for unknown types', () => {
    const r = svc.format(
      'escrow_refunded',
      'en',
      {},
      { title: 'T', body: 'B' },
    );
    expect(r).toEqual({ title: 'T', body: 'B' });
  });
});
