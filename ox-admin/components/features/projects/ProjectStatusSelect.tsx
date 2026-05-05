'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { Button } from '@/components/ui/Button'
import { Modal } from '@/components/ui/Modal'
import { useUpdateProjectStatus } from '@/lib/queries/useProjects'
import toast from 'react-hot-toast'

export const PROJECT_STATUS_TRANSITIONS: Record<string, string[]> = {
  draft:           ['READY'],
  matched:         [],
  contract_signed: ['PAY'],
  active_escrow:   ['START'],
  in_execution:    ['COMPLETE'],
  closing:         ['CONFIRM'],
}

export function hasStatusTransitions(status: string): boolean {
  return (PROJECT_STATUS_TRANSITIONS[status] ?? []).length > 0
}

interface Props {
  projectId: string
  currentStatus: string
}

export function ProjectStatusSelect({ projectId, currentStatus }: Props) {
  const t = useTranslations('projectStatus')
  const tCommon = useTranslations('common')
  const available = PROJECT_STATUS_TRANSITIONS[currentStatus] ?? []
  const [selected, setSelected] = useState<string | null>(null)
  const { mutate, isPending } = useUpdateProjectStatus()

  const handleConfirm = () => {
    if (!selected) return
    mutate({ id: projectId, event: selected }, {
      onSuccess: () => { toast.success(t('toastOk')); setSelected(null) },
      onError: () => toast.error(t('toastErr')),
    })
  }

  const labelFor = (event: string) =>
    t(event as 'READY' | 'PAY' | 'START' | 'COMPLETE' | 'CONFIRM')

  if (available.length === 0) return null

  return (
    <>
      <div className="flex gap-2 flex-wrap">
        {available.map((event) => (
          <Button
            key={event}
            variant="secondary"
            size="sm"
            onClick={() => setSelected(event)}
          >
            {labelFor(event)}
          </Button>
        ))}
      </div>

      <Modal
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        title={t('confirmTitle')}
      >
        <p className="text-text-secondary mb-6">
          {t('confirmPrompt', { action: selected ? labelFor(selected) : '' })}
        </p>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={() => setSelected(null)}>
            {tCommon('cancel')}
          </Button>
          <Button
            variant="primary"
            isLoading={isPending}
            onClick={handleConfirm}
          >
            {tCommon('confirm')}
          </Button>
        </div>
      </Modal>
    </>
  )
}
