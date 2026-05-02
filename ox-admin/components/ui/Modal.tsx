'use client'
import { cn } from '@/lib/utils/cn'
import { X } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { ReactNode } from 'react'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title?: string
  children: ReactNode
  className?: string
}

export function Modal({ isOpen, onClose, title, children, className }: ModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="fixed inset-0 bg-black/60 z-40"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />
          <motion.div
            className={cn(
              'fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-50',
              'bg-surface border border-divider rounded-card shadow-xl',
              'w-full max-w-md p-6',
              className,
            )}
            initial={{ opacity: 0, scale: 0.95, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 10 }}
          >
            {title && (
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-white">{title}</h2>
                <button onClick={onClose} className="text-text-secondary hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>
            )}
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
