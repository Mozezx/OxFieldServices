'use client'

import { useState } from 'react'
import axios from 'axios'
import { useTranslations } from 'next-intl'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Modal } from '@/components/ui/Modal'
import { WorkerRatingStars } from '../workers/WorkerRatingStars'
import { useAssignWorker } from '@/lib/queries/useWorkers'
import type { Candidate } from '@/lib/queries/useWorkers'
import toast from 'react-hot-toast'

interface CandidatesCardProps {
  projectId: string
  candidates: Candidate[]
  currentWorkerName?: string | null
  disabled?: boolean
}

export function CandidatesCard({
  projectId,
  candidates,
  currentWorkerName,
  disabled,
}: CandidatesCardProps) {
  const t = useTranslations('candidates')
  const tCommon = useTranslations('common')
  const [selected, setSelected] = useState<Candidate | null>(null)
  const { mutate, isPending } = useAssignWorker()
  const isSwap = !!currentWorkerName

  const handleAssign = () => {
    if (!selected) return
    mutate({ projectId, workerId: selected.id }, {
      onSuccess: () => {
        toast.success(isSwap ? t('toastSwapped') : t('toastAssigned'))
        setSelected(null)
      },
      onError: (error) => {
        let message = isSwap ? t('errorSwap') : t('errorAssign')
        if (axios.isAxiosError(error)) {
          const data = error.response?.data as { message?: string | string[] } | undefined
          const apiMessage = Array.isArray(data?.message) ? data?.message.join(', ') : data?.message
          if (apiMessage) message = apiMessage
        }
        toast.error(message)
      },
    })
  }

  return (
    <>
      <div className="space-y-3">
        {candidates.map((c) => (
          <Card key={c.id} className="hover:border-accent/50 transition-colors">
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <div className="w-10 h-10 rounded-full bg-surface2 flex items-center justify-center text-accent font-bold">
                    {c.user.name[0]}
                  </div>
                  <div>
                    <p className="text-white font-medium">{c.user.name}</p>
                    <WorkerRatingStars rating={Number(c.rating)} size="sm" />
                  </div>
                </div>

                <div className="mb-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs text-text-secondary">{t('compatibility')}</span>
                    <span className="text-xs font-bold text-accent">{c.matchScore}%</span>
                  </div>
                  <div className="w-full bg-surface2 rounded-full h-2">
                    <div
                      className="bg-accent h-2 rounded-full transition-all"
                      style={{ width: `${c.matchScore}%` }}
                    />
                  </div>
                </div>

                <div className="flex flex-wrap gap-1.5">
                  {c.matchingSkills?.map((s) => (
                    <span key={s} className="text-xs bg-accent/10 text-accent px-2 py-0.5 rounded-full">{s}</span>
                  ))}
                  {c.missingSkills?.map((s) => (
                    <span key={s} className="text-xs bg-white/5 text-text-disabled px-2 py-0.5 rounded-full">{s}</span>
                  ))}
                </div>
              </div>

              <Button
                variant="primary"
                size="sm"
                disabled={disabled}
                onClick={() => setSelected(c)}
              >
                {isSwap ? t('swap') : t('assign')}
              </Button>
            </div>
          </Card>
        ))}
      </div>

      <Modal
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        title={isSwap ? t('confirmSwapTitle') : t('confirmAssignTitle')}
      >
        {isSwap ? (
          <p className="text-text-secondary mb-6">
            {t('confirmSwapBody', {
              current: currentWorkerName ?? '',
              selected: selected?.user.name ?? '',
            })}
          </p>
        ) : (
          <p className="text-text-secondary mb-6">
            {t('confirmAssignBody', { selected: selected?.user.name ?? '' })}
          </p>
        )}
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={() => setSelected(null)}>{tCommon('cancel')}</Button>
          <Button variant="primary" isLoading={isPending} onClick={handleAssign}>
            {isSwap ? t('confirmSwapAction') : tCommon('confirm')}
          </Button>
        </div>
      </Modal>
    </>
  )
}
