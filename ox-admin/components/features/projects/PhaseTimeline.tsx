'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { X } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { Badge } from '@/components/ui/Badge'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import type { Phase } from '@/lib/queries/useProjects'

interface PhaseTimelineProps {
  phases: Phase[]
}

export function PhaseTimeline({ phases }: PhaseTimelineProps) {
  const t = useTranslations('phaseTimeline')
  const sorted = [...phases].sort((a, b) => a.order - b.order)
  const [lightboxUrl, setLightboxUrl] = useState<string | null>(null)

  return (
    <>
      <div className="overflow-x-auto pb-2">
        <div className="flex items-stretch gap-3 min-w-max">
        {sorted.map((phase, i) => (
          <div key={phase.id} className="flex items-center gap-3">
            <div className="w-[260px] rounded-lg border border-divider bg-surface/40 p-4">
              <div className="flex items-center justify-between mb-3">
                <div className="w-8 h-8 rounded-full bg-surface2 border border-divider flex items-center justify-center text-xs text-text-secondary font-medium">
                  {i + 1}
                </div>
                <Badge status={phase.status} />
              </div>
              <div className="flex items-start justify-between gap-3">
                <span className="text-white font-medium text-sm leading-snug">{phase.name}</span>
                <span className="text-text-secondary text-sm whitespace-nowrap">{formatCurrency(Number(phase.amount))}</span>
              </div>
              {phase.evidences && phase.evidences.length > 0 && (
                <div className="mt-2 flex gap-2 flex-wrap">
                  {phase.evidences.map((ev) => (
                    <button
                      key={ev.id}
                      type="button"
                      onClick={() => setLightboxUrl(ev.url)}
                      className="w-16 h-16 rounded overflow-hidden border border-divider hover:border-accent transition-colors focus:outline-none focus:ring-2 focus:ring-accent"
                    >
                      <img
                        src={ev.url}
                        alt={t('evidenceAlt')}
                        className="w-full h-full object-cover"
                      />
                    </button>
                  ))}
                </div>
              )}
            </div>
            {i < sorted.length - 1 && <div className="h-px w-6 bg-divider" />}
          </div>
        ))}
        </div>
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
              type="button"
              className="absolute top-4 right-4 text-white/70 hover:text-white transition-colors"
              onClick={() => setLightboxUrl(null)}
            >
              <X className="w-7 h-7" />
            </button>
            <motion.img
              src={lightboxUrl}
              alt={t('evidenceExpandedAlt')}
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
