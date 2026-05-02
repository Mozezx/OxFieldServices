'use client'
import { useState } from 'react'
import { X } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { Badge } from '@/components/ui/Badge'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import type { Phase } from '@/lib/queries/useProjects'

interface PhaseTimelineProps {
  phases: Phase[]
}

export function PhaseTimeline({ phases }: PhaseTimelineProps) {
  const sorted = [...phases].sort((a, b) => a.order - b.order)
  const [lightboxUrl, setLightboxUrl] = useState<string | null>(null)

  return (
    <>
      <div className="space-y-3">
        {sorted.map((phase, i) => (
          <div key={phase.id} className="flex items-start gap-4">
            <div className="flex flex-col items-center">
              <div className="w-8 h-8 rounded-full bg-surface2 border border-divider flex items-center justify-center text-xs text-text-secondary font-medium">
                {i + 1}
              </div>
              {i < sorted.length - 1 && (
                <div className="w-px h-8 bg-divider mt-1" />
              )}
            </div>
            <div className="flex-1 pb-4">
              <div className="flex items-center justify-between">
                <span className="text-white font-medium text-sm">{phase.name}</span>
                <div className="flex items-center gap-3">
                  <span className="text-text-secondary text-sm">{formatCurrency(Number(phase.amount))}</span>
                  <Badge status={phase.status} />
                </div>
              </div>
              {phase.evidences && phase.evidences.length > 0 && (
                <div className="mt-2 flex gap-2 flex-wrap">
                  {phase.evidences.map((ev) => (
                    <button
                      key={ev.id}
                      onClick={() => setLightboxUrl(ev.url)}
                      className="w-16 h-16 rounded overflow-hidden border border-divider hover:border-accent transition-colors focus:outline-none focus:ring-2 focus:ring-accent"
                    >
                      <img
                        src={ev.url}
                        alt="Evidência"
                        className="w-full h-full object-cover"
                      />
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      <AnimatePresence>
        {lightboxUrl && (
          <motion.div
            className="fixed inset-0 bg-black/90 z-50 flex items-center justify-center"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setLightboxUrl(null)}
          >
            <button
              className="absolute top-4 right-4 text-white/70 hover:text-white transition-colors"
              onClick={() => setLightboxUrl(null)}
            >
              <X className="w-7 h-7" />
            </button>
            <motion.img
              src={lightboxUrl}
              alt="Evidência expandida"
              className="max-w-[90vw] max-h-[90vh] object-contain rounded-lg"
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}
