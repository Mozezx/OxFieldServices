'use client'
import { Bell, User } from 'lucide-react'

interface HeaderProps {
  title: string
  userEmail?: string
}

export function Header({ title, userEmail }: HeaderProps) {
  return (
    <header className="h-16 bg-primary border-b border-divider flex items-center justify-between px-6 flex-shrink-0">
      <h1 className="text-white font-semibold text-lg">{title}</h1>
      <div className="flex items-center gap-4">
        <button className="text-text-secondary hover:text-white relative">
          <Bell className="w-5 h-5" />
        </button>
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
