'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import Image from 'next/image'
import {
  Briefcase, Users, CreditCard, Shuffle, Wrench, Bell,
  LogOut, ChevronLeft, ChevronRight,
} from 'lucide-react'
import { cn } from '@/lib/utils/cn'
import { signOut } from '@/lib/auth'
import { useState } from 'react'

const navItems = [
  { href: '/projects', icon: Briefcase, label: 'Projetos' },
  { href: '/workers',  icon: Users,     label: 'Workers' },
  { href: '/payments', icon: CreditCard, label: 'Pagamentos' },
  { href: '/notifications', icon: Bell, label: 'Notificações' },
  { href: '/skills',   icon: Wrench,    label: 'Skills' },
]

export function Sidebar() {
  const pathname = usePathname()
  const [collapsed, setCollapsed] = useState(false)

  return (
    <aside
      className={cn(
        'flex flex-col h-screen bg-primary border-r border-divider transition-all duration-300',
        collapsed ? 'w-16' : 'w-60',
      )}
    >
      {/* Logo */}
      <div className={cn('flex items-center h-16 px-4 border-b border-divider', collapsed ? 'justify-center' : 'justify-between')}>
        {!collapsed && (
          <span className="text-accent font-bold text-lg tracking-wide">OX Admin</span>
        )}
        <button
          onClick={() => setCollapsed((v) => !v)}
          className="text-text-secondary hover:text-white p-1 rounded"
        >
          {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
        </button>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-2 py-4 space-y-1">
        {navItems.map(({ href, icon: Icon, label }) => {
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
              {!collapsed && <span>{label}</span>}
            </Link>
          )
        })}
      </nav>

      {/* Logout */}
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
            {!collapsed && <span>Sair</span>}
          </button>
        </form>
      </div>
    </aside>
  )
}
