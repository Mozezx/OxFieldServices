import { cn } from '@/lib/utils/cn'
import { HTMLAttributes } from 'react'

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  padding?: boolean
}

export function Card({ className, padding = true, children, ...props }: CardProps) {
  return (
    <div
      {...props}
      className={cn(
        'bg-surface rounded-card border border-divider',
        padding && 'p-6',
        className,
      )}
    >
      {children}
    </div>
  )
}
