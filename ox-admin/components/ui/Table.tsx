import { cn } from '@/lib/utils/cn'
import { ReactNode } from 'react'

export function Table({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn('overflow-x-auto', className)}>
      <table className="w-full text-sm text-left">{children}</table>
    </div>
  )
}

export function Thead({ children }: { children: ReactNode }) {
  return (
    <thead className="border-b border-divider text-text-secondary text-xs uppercase tracking-wide">
      {children}
    </thead>
  )
}

export function Tbody({ children }: { children: ReactNode }) {
  return <tbody className="divide-y divide-divider/50">{children}</tbody>
}

export function Th({ children, className }: { children: ReactNode; className?: string }) {
  return <th className={cn('px-4 py-3 font-medium', className)}>{children}</th>
}

export function Td({ children, className }: { children: ReactNode; className?: string }) {
  return <td className={cn('px-4 py-3 text-white', className)}>{children}</td>
}

export function Tr({ children, className, onClick }: { children: ReactNode; className?: string; onClick?: () => void }) {
  return (
    <tr
      onClick={onClick}
      className={cn('hover:bg-surface2/50 transition-colors', onClick && 'cursor-pointer', className)}
    >
      {children}
    </tr>
  )
}
