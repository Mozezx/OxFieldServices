'use client'
import { useState } from 'react'
import { Button } from '@/components/ui/Button'
import { Modal } from '@/components/ui/Modal'
import { useUpdateProjectStatus } from '@/lib/queries/useProjects'
import toast from 'react-hot-toast'

// ASSIGN não está aqui de propósito: a transição matched → contract_signed
// é feita exclusivamente pelo fluxo de matching (POST /matching/:id/assign),
// que cria o contrato. Acioná-la manualmente deixaria o estado inconsistente.
export const PROJECT_STATUS_TRANSITIONS: Record<string, string[]> = {
  draft:           [],
  in_validation:   ['APPROVE', 'REJECT'],
  matched:         [],
  contract_signed: ['PAY'],
  active_escrow:   ['START'],
  in_execution:    ['COMPLETE'],
  closing:         ['CONFIRM'],
}

export function hasStatusTransitions(status: string): boolean {
  return (PROJECT_STATUS_TRANSITIONS[status] ?? []).length > 0
}

const eventLabels: Record<string, string> = {
  SUBMIT:  'Enviar para validação',
  APPROVE: 'Aprovar',
  REJECT:  'Rejeitar',
  PAY:     'Confirmar pagamento',
  START:   'Iniciar execução',
  COMPLETE:'Marcar como concluído',
  CONFIRM: 'Confirmar encerramento',
}

interface Props {
  projectId: string
  currentStatus: string
}

export function ProjectStatusSelect({ projectId, currentStatus }: Props) {
  const available = PROJECT_STATUS_TRANSITIONS[currentStatus] ?? []
  const [selected, setSelected] = useState<string | null>(null)
  const { mutate, isPending } = useUpdateProjectStatus()

  const handleConfirm = () => {
    if (!selected) return
    mutate({ id: projectId, event: selected }, {
      onSuccess: () => { toast.success('Status atualizado'); setSelected(null) },
      onError: () => toast.error('Falha ao atualizar status'),
    })
  }

  if (available.length === 0) return null

  return (
    <>
      <div className="flex gap-2 flex-wrap">
        {available.map((event) => (
          <Button
            key={event}
            variant={event === 'REJECT' ? 'danger' : 'secondary'}
            size="sm"
            onClick={() => setSelected(event)}
          >
            {eventLabels[event] ?? event}
          </Button>
        ))}
      </div>

      <Modal
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        title="Confirmar ação"
      >
        <p className="text-text-secondary mb-6">
          Confirmar: <span className="text-white font-medium">{eventLabels[selected ?? '']}</span>?
        </p>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={() => setSelected(null)}>Cancelar</Button>
          <Button
            variant={selected === 'REJECT' ? 'danger' : 'primary'}
            isLoading={isPending}
            onClick={handleConfirm}
          >
            Confirmar
          </Button>
        </div>
      </Modal>
    </>
  )
}
