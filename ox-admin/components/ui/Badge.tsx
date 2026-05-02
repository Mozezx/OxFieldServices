import { cn } from '@/lib/utils/cn'

const statusConfig: Record<string, { label: string; className: string }> = {
  draft:           { label: 'Rascunho',      className: 'bg-white/10 text-text-secondary' },
  in_validation:   { label: 'Em Validação',  className: 'bg-warning/15 text-warning' },
  matched:         { label: 'Match feito',   className: 'bg-accent/15 text-accent' },
  contract_signed: { label: 'Contrato ass.', className: 'bg-accent/15 text-accent' },
  active_escrow:   { label: 'Escrow ativo',  className: 'bg-accent/15 text-accent' },
  in_execution:    { label: 'Em execução',   className: 'bg-accent/20 text-accent font-semibold' },
  closing:         { label: 'Encerrando',    className: 'bg-warning/15 text-warning' },
  closed:          { label: 'Concluído',     className: 'bg-accent/15 text-accent' },
  rejected:        { label: 'Rejeitado',     className: 'bg-error/15 text-error' },
  pending:         { label: 'Pendente',      className: 'bg-white/10 text-text-secondary' },
  in_progress:     { label: 'Em andamento',  className: 'bg-accent/20 text-accent' },
  validated:       { label: 'Validada',      className: 'bg-accent/15 text-accent' },
  available:       { label: 'Disponível',    className: 'bg-accent/15 text-accent' },
  occupied:        { label: 'Ocupado',       className: 'bg-warning/15 text-warning' },
  inactive:        { label: 'Inativo',       className: 'bg-white/10 text-text-secondary' },
  held:            { label: 'Em Escrow',     className: 'bg-accent/15 text-accent' },
  released:        { label: 'Liberado',      className: 'bg-accent/20 text-accent' },
  refunded:        { label: 'Reembolsado',   className: 'bg-error/15 text-error' },
}

interface BadgeProps {
  status: string
  className?: string
}

export function Badge({ status, className }: BadgeProps) {
  const config = statusConfig[status] ?? { label: status, className: 'bg-white/10 text-text-secondary' }
  return (
    <span className={cn('inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs', config.className, className)}>
      <span className="w-1.5 h-1.5 rounded-full bg-current" />
      {config.label}
    </span>
  )
}
