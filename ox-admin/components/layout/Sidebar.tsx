'use client'

import { usePathname } from '@/i18n/navigation'
import { Link } from '@/i18n/navigation'
import Image from 'next/image'
import {
  Briefcase, Users, CreditCard, Wrench, Bell,
  LogOut,
} from 'lucide-react'
import { useTranslations } from 'next-intl'
import { cn } from '@/lib/utils/cn'
import { signOut } from '@/lib/auth'
import { useState } from 'react'

export function Sidebar() {
  const pathname = usePathname()
  const t = useTranslations('nav')
  const [collapsed, setCollapsed] = useState(true)

  const navItems = [
    { href: '/projects', icon: Briefcase, labelKey: 'projects' as const },
    { href: '/workers', icon: Users, labelKey: 'workers' as const },
    { href: '/payments', icon: CreditCard, labelKey: 'payments' as const },
    { href: '/notifications', icon: Bell, labelKey: 'notifications' as const },
    { href: '/skills', icon: Wrench, labelKey: 'skills' as const },
  ]

  return (
    <aside
      onMouseEnter={() => setCollapsed(false)}
      onMouseLeave={() => setCollapsed(true)}
      className={cn(
        'flex flex-col h-screen bg-primary border-r border-divider transition-all duration-300',
        collapsed ? 'w-16' : 'w-60',
      )}
    >
      <div className="flex items-center justify-center h-16 px-2 border-b border-divider">
        <Link href="/" aria-label={t('brand')}>
          <Image
            src="/logo.webp"
            alt={t('brand')}
            width={collapsed ? 64 : 190}
            height={collapsed ? 42 : 52}
            className={cn('w-auto object-contain transition-all duration-300', collapsed ? 'h-10' : 'h-12')}
            priority
          />
        </Link>
      </div>

      <nav className="flex-1 px-2 py-4 space-y-1">
        {navItems.map(({ href, icon: Icon, labelKey }) => {
          const active = pathname.startsWith(href)
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                'flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors text-sm font-medium',
                active
                  ? 'bg-accent/10 text-white border-l-[3px] border-accent'
                  : 'text-text-secondary hover:bg-surface hover:text-white',
                collapsed && 'justify-center',
              )}
            >
              <Icon className={cn('w-5 h-5 flex-shrink-0', active ? 'text-accent' : 'text-text-secondary')} />
              {!collapsed && <span>{t(labelKey)}</span>}
            </Link>
          )
        })}
      </nav>

      <div className="px-2 pb-4 border-t border-divider pt-4">
        <form action={signOut}>
          <button
            type="submit"
            className={cn(
              'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-text-secondary hover:text-error hover:bg-error/10 transition-colors text-sm',
              collapsed && 'justify-center',
            )}
          >
            <LogOut className="w-5 h-5 flex-shrink-0" />
            {!collapsed && <span>{t('logout')}</span>}
          </button>
        </form>
      </div>
    </aside>
  )
}
