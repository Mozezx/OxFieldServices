'use client'
import Link from 'next/link'
import { Bell, User } from 'lucide-react'
import { useUnreadNotificationsCount } from '@/lib/queries/useNotifications'

interface HeaderProps {
  title: string
  userEmail?: string
}

export function Header({ title, userEmail }: HeaderProps) {
  const { data: unread = 0 } = useUnreadNotificationsCount()

  return (
    <header className="sticky top-0 z-20 h-16 shrink-0 bg-primary border-b border-divider flex items-center justify-between px-6">
      <h1 className="text-white font-semibold text-lg">{title}</h1>
      <div className="flex items-center gap-4">
        <Link
          href="/notifications"
          prefetch
          className="relative inline-flex min-h-10 min-w-10 items-center justify-center rounded-lg p-2 text-text-secondary transition-colors hover:bg-surface1 hover:text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent"
          aria-label="Abrir central de notificações"
          title="Notificações"
        >
          <Bell className="pointer-events-none h-5 w-5" aria-hidden />
          {unread > 0 ? (
            <span className="pointer-events-none absolute -right-0.5 -top-0.5 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-red-600 px-1 text-[10px] font-bold text-white">
              {unread > 99 ? '99+' : unread}
            </span>
          ) : null}
        </Link>
        <div className="flex items-center gap-2 text-sm text-text-secondary">
          <div className="w-8 h-8 rounded-full bg-surface2 flex items-center justify-center">
            <User className="w-4 h-4 text-accent" />
          </div>
          <span>{userEmail ?? 'Admin'}</span>
        </div>
      </div>
    </header>
  )
}
