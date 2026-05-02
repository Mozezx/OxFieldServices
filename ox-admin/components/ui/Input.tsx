'use client'
import { cn } from '@/lib/utils/cn'
import { Eye, EyeOff } from 'lucide-react'
import { InputHTMLAttributes, useState } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
}

export function Input({ label, error, className, type, ...props }: InputProps) {
  const [showPassword, setShowPassword] = useState(false)
  const isPassword = type === 'password'

  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label className="text-sm font-medium text-white">{label}</label>
      )}
      <div className="relative">
        <input
          {...props}
          type={isPassword && showPassword ? 'text' : type}
          className={cn(
            'w-full bg-surface2 border border-divider rounded-input px-4 py-2.5 text-white placeholder:text-text-disabled',
            'focus:outline-none focus:border-accent transition-colors',
            error && 'border-error focus:border-error',
            isPassword && 'pr-10',
            className,
          )}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPassword((v) => !v)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-text-secondary hover:text-white"
          >
            {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>
        )}
      </div>
      {error && <p className="text-xs text-error">{error}</p>}
    </div>
  )
}
