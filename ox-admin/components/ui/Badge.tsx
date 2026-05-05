'use client'

import { useTranslations } from 'next-intl'
import { cn } from '@/lib/utils/cn'

const statusConfig: Record<string, { className: string }> = {
  draft:           { className: 'bg-white/10 text-text-secondary' },
  matched:         { className: 'bg-accent/15 text-accent' },
  contract_signed: { className: 'bg-accent/15 text-accent' },
  active_escrow:   { className: 'bg-accent/15 text-accent' },
  in_execution:    { className: 'bg-accent/20 text-accent font-semibold' },
  closing:         { className: 'bg-warning/15 text-warning' },
  closed:          { className: 'bg-accent/15 text-accent' },
  rejected:        { className: 'bg-error/15 text-error' },
  pending:         { className: 'bg-white/10 text-text-secondary' },
  in_progress:     { className: 'bg-accent/20 text-accent' },
  validated:       { className: 'bg-accent/15 text-accent' },
  available:       { className: 'bg-accent/15 text-accent' },
  occupied:        { className: 'bg-warning/15 text-warning' },
  inactive:        { className: 'bg-white/10 text-text-secondary' },
  held:            { className: 'bg-accent/15 text-accent' },
  released:        { className: 'bg-accent/20 text-accent' },
  refunded:        { className: 'bg-error/15 text-error' },
}

const BADGE_KEYS = [
  'draft', 'matched', 'contract_signed', 'active_escrow', 'in_execution',
  'closing', 'closed', 'rejected', 'pending', 'in_progress', 'validated', 'available',
  'occupied', 'inactive', 'held', 'released', 'refunded',
] as const

function isBadgeKey(status: string): status is (typeof BADGE_KEYS)[number] {
  return (BADGE_KEYS as readonly string[]).includes(status)
}

interface BadgeProps {
  status: string
  className?: string
}

export function Badge({ status, className }: BadgeProps) {
  const t = useTranslations('badge')
  const config = statusConfig[status] ?? { className: 'bg-white/10 text-text-secondary' }
  const label = isBadgeKey(status) ? t(status) : status

  return (
    <span className={cn('inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs', config.className, className)}>
      <span className="w-1.5 h-1.5 rounded-full bg-current" />
      {label}
    </span>
  )
}
