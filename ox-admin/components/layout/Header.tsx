'use client'

import { Bell, User } from 'lucide-react'
import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'
import { LanguageSwitcher } from '@/components/layout/LanguageSwitcher'
import { useUnreadNotificationsCount } from '@/lib/queries/useNotifications'
import { useAuthMe } from '@/lib/queries/useAuthMe'

interface HeaderProps {
  title: string
}

export function Header({ title }: HeaderProps) {
  const t = useTranslations('header')
  const tRoles = useTranslations('roles')
  const { data: unread = 0 } = useUnreadNotificationsCount()
  const { data: me } = useAuthMe()

  const roleLabel = (role: string) => {
    if (role === 'admin' || role === 'client' || role === 'worker') {
      return tRoles(role)
    }
    return role
  }

  return (
    <header className="relative z-20 h-16 shrink-0 bg-primary border-b border-divider flex items-center justify-between px-6">
      <h1 className="text-white font-semibold text-lg">{title}</h1>
      <div className="flex items-center gap-4">
        <LanguageSwitcher />
        <Link
          href="/notifications"
          prefetch
          className="relative inline-flex min-h-10 min-w-10 items-center justify-center rounded-lg p-2 text-text-secondary transition-colors hover:bg-surface1 hover:text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent"
          aria-label={t('notificationsAria')}
          title={t('notificationsTitle')}
        >
          <Bell className="pointer-events-none h-5 w-5" aria-hidden />
          {unread > 0 ? (
            <span className="pointer-events-none absolute -right-0.5 -top-0.5 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-red-600 px-1 text-[10px] font-bold text-white">
              {unread > 99 ? '99+' : unread}
            </span>
          ) : null}
        </Link>
        <div className="flex flex-col items-end gap-0.5 text-sm text-text-secondary">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-surface2 flex items-center justify-center">
              <User className="w-4 h-4 text-accent" />
            </div>
            <div className="flex flex-col items-end leading-tight">
              <span className="text-white font-medium">{me?.name ?? '—'}</span>
              <span className="text-xs max-w-[220px] truncate" title={me?.email}>
                {me?.email ?? t('loadingUser')}
              </span>
            </div>
          </div>
          {me?.role ? (
            <span className="text-[11px] uppercase tracking-wide text-text-secondary/80">
              {roleLabel(me.role)}
            </span>
          ) : null}
        </div>
      </div>
    </header>
  )
}
