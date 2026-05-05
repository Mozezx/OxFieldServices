'use client'

import { useState } from 'react'
import { useRouter } from '@/i18n/navigation'
import { useTranslations } from 'next-intl'
import toast from 'react-hot-toast'
import { PlusCircle, Trash2, ChevronRight, ChevronLeft, Check } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { useLookupOrCreateClient, ClientLookup } from '@/lib/queries/useClients'
import { useCreateProject } from '@/lib/queries/useProjects'

interface PhaseInput {
  name: string
  order: number
  amount: string
}

const STEPS = ['client', 'project', 'phases', 'review'] as const
type Step = (typeof STEPS)[number]

export function CreateProjectForm() {
  const t = useTranslations('createProject')
  const router = useRouter()

  const [step, setStep] = useState<Step>('client')
  const [unregistered, setUnregistered] = useState(false)
  const [email, setEmail] = useState('')
  const [clientName, setClientName] = useState('')
  const [clientPhone, setClientPhone] = useState('')
  const [resolvedClient, setResolvedClient] = useState<ClientLookup | null>(null)

  const [title, setTitle] = useState('')
  const [location, setLocation] = useState('')
  const [budget, setBudget] = useState('')
  const [deadline, setDeadline] = useState('')

  const [phases, setPhases] = useState<PhaseInput[]>([{ name: '', order: 1, amount: '' }])

  const lookupMut = useLookupOrCreateClient()
  const createMut = useCreateProject()

  const stepIndex = STEPS.indexOf(step)

  function addPhase() {
    setPhases((prev) => [...prev, { name: '', order: prev.length + 1, amount: '' }])
  }

  function removePhase(i: number) {
    setPhases((prev) => prev.filter((_, idx) => idx !== i).map((p, idx) => ({ ...p, order: idx + 1 })))
  }

  function updatePhase(i: number, field: keyof PhaseInput, value: string) {
    setPhases((prev) => prev.map((p, idx) => (idx === i ? { ...p, [field]: value } : p)))
  }

  async function handleLookup() {
    if (!unregistered && !email) return
    try {
      const client = await lookupMut.mutateAsync(
        unregistered
          ? { unregistered: true, name: clientName || undefined, phone: clientPhone || undefined }
          : { email, name: clientName || undefined, phone: clientPhone || undefined },
      )
      setResolvedClient(client)
      setStep('project')
    } catch {
      toast.error(t('errorLookup'))
    }
  }

  async function handleSubmit(submit: boolean) {
    if (!resolvedClient) return
    try {
      const project = await createMut.mutateAsync({
        title,
        budget: parseFloat(budget),
        location,
        deadline: deadline || undefined,
        clientId: resolvedClient.id,
        submit,
        phases: phases
          .filter((p) => p.name && p.amount)
          .map((p) => ({ name: p.name, order: p.order, amount: parseFloat(p.amount) })),
      })
      toast.success(t('created'))
      router.push(`/projects/${project.id}`)
    } catch {
      toast.error(t('errorCreate'))
    }
  }

  const phasesTotal = phases.reduce((s, p) => s + (parseFloat(p.amount) || 0), 0)
  const budgetNum = parseFloat(budget) || 0
  const phasesWarning = phases.some((p) => p.name && p.amount) && Math.abs(phasesTotal - budgetNum) > 0.01

  return (
    <div className="w-full max-w-2xl mx-auto space-y-6">
      {/* Step indicator */}
      <div className="flex items-center justify-center gap-2 flex-wrap">
        {STEPS.map((s, i) => (
          <div key={s} className="flex items-center gap-2">
            <div
              className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold transition-colors ${
                i < stepIndex
                  ? 'bg-accent text-primary'
                  : i === stepIndex
                    ? 'bg-accent/20 border-2 border-accent text-accent'
                    : 'bg-surface text-text-disabled border border-divider'
              }`}
            >
              {i < stepIndex ? <Check className="w-4 h-4" /> : i + 1}
            </div>
            {i < STEPS.length - 1 && (
              <div className={`h-px w-8 ${i < stepIndex ? 'bg-accent' : 'bg-divider'}`} />
            )}
          </div>
        ))}
        <span className="text-text-secondary text-sm">
          {t(`stepLabel.${step}`)}
        </span>
      </div>

      {/* Step: Client */}
      {step === 'client' && (
        <Card>
          <h3 className="text-white font-semibold mb-4">{t('stepClientTitle')}</h3>

          {/* Radio buttons */}
          <div className="flex gap-4 mb-4">
            {[
              { value: false, label: t('clientTypeEmail') },
              { value: true, label: t('clientTypeUnregistered') },
            ].map(({ value, label }) => (
              <button
                key={String(value)}
                type="button"
                onClick={() => setUnregistered(value)}
                className={`flex items-center gap-2 text-sm px-3 py-2 rounded-lg border transition-colors ${
                  unregistered === value
                    ? 'border-accent text-accent bg-accent/10'
                    : 'border-divider text-text-secondary hover:border-accent/50'
                }`}
              >
                <span
                  className={`w-4 h-4 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${
                    unregistered === value ? 'border-accent' : 'border-divider'
                  }`}
                >
                  {unregistered === value && <span className="w-2 h-2 rounded-full bg-accent" />}
                </span>
                {label}
              </button>
            ))}
          </div>

          {unregistered ? (
            <p className="text-xs text-text-secondary mb-3">{t('unregisteredClientHint')}</p>
          ) : (
            <div className="space-y-3">
              <div>
                <label className="block text-xs text-text-secondary mb-1">{t('emailLabel')} *</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="cliente@exemplo.com"
                  className="w-full bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
              </div>
              <div>
                <label className="block text-xs text-text-secondary mb-1">{t('clientNameLabel')}</label>
                <input
                  type="text"
                  value={clientName}
                  onChange={(e) => setClientName(e.target.value)}
                  placeholder={t('clientNamePlaceholder')}
                  className="w-full bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
              </div>
              <div>
                <label className="block text-xs text-text-secondary mb-1">{t('clientPhoneLabel')}</label>
                <input
                  type="tel"
                  value={clientPhone}
                  onChange={(e) => setClientPhone(e.target.value)}
                  placeholder="+351 912 345 678"
                  className="w-full bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
              </div>
            </div>
          )}

          {resolvedClient && (
            <div className="mt-3 p-3 rounded-lg bg-accent/10 border border-accent/30 text-sm">
              <span className="text-accent font-medium">{resolvedClient.name}</span>
              <span className="text-text-secondary ml-2">
                {resolvedClient.isNew ? `(${t('newClient')})` : `(${t('existingClient')})`}
              </span>
            </div>
          )}
          <div className="mt-4 flex justify-end">
            <Button
              variant="primary"
              onClick={handleLookup}
              disabled={(!unregistered && !email) || lookupMut.isPending}
            >
              {lookupMut.isPending ? t('searching') : t('searchClient')}
              <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </Card>
      )}

      {/* Step: Project data */}
      {step === 'project' && (
        <Card>
          <h3 className="text-white font-semibold mb-4">{t('stepProjectTitle')}</h3>
          <div className="space-y-3">
            {[
              { label: t('titleLabel'), value: title, onChange: setTitle, type: 'text', placeholder: t('titlePlaceholder') },
              { label: t('locationLabel'), value: location, onChange: setLocation, type: 'text', placeholder: t('locationPlaceholder') },
              { label: t('budgetLabel'), value: budget, onChange: setBudget, type: 'number', placeholder: '0.00' },
              { label: t('deadlineLabel'), value: deadline, onChange: setDeadline, type: 'date', placeholder: '' },
            ].map(({ label, value, onChange, type, placeholder }) => (
              <div key={label}>
                <label className="block text-xs text-text-secondary mb-1">{label}</label>
                <input
                  type={type}
                  value={value}
                  onChange={(e) => onChange(e.target.value)}
                  placeholder={placeholder}
                  className="w-full bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
              </div>
            ))}
          </div>
          <div className="mt-4 flex justify-between">
            <Button variant="secondary" onClick={() => setStep('client')}>
              <ChevronLeft className="w-4 h-4 mr-1" /> {t('back')}
            </Button>
            <Button
              variant="primary"
              onClick={() => setStep('phases')}
              disabled={!title || !location || !budget}
            >
              {t('next')} <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </Card>
      )}

      {/* Step: Phases */}
      {step === 'phases' && (
        <Card>
          <h3 className="text-white font-semibold mb-4">{t('stepPhasesTitle')}</h3>
          <div className="space-y-3">
            {phases.map((phase, i) => (
              <div key={i} className="flex gap-2 items-center">
                <span className="text-text-disabled text-sm w-5">{i + 1}.</span>
                <input
                  type="text"
                  value={phase.name}
                  onChange={(e) => updatePhase(i, 'name', e.target.value)}
                  placeholder={t('phaseNamePlaceholder')}
                  className="flex-1 bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
                <input
                  type="number"
                  value={phase.amount}
                  onChange={(e) => updatePhase(i, 'amount', e.target.value)}
                  placeholder="0.00"
                  className="w-28 bg-surface border border-divider rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-accent"
                />
                {phases.length > 1 && (
                  <button onClick={() => removePhase(i)} className="text-error hover:text-error/80">
                    <Trash2 className="w-4 h-4" />
                  </button>
                )}
              </div>
            ))}
          </div>
          {phasesWarning && (
            <p className="mt-2 text-xs text-warning">
              {t('phasesWarning', { total: phasesTotal.toFixed(2), budget: budgetNum.toFixed(2) })}
            </p>
          )}
          <button
            onClick={addPhase}
            className="mt-3 flex items-center gap-2 text-accent text-sm hover:text-accent/80"
          >
            <PlusCircle className="w-4 h-4" /> {t('addPhase')}
          </button>
          <div className="mt-4 flex justify-between">
            <Button variant="secondary" onClick={() => setStep('project')}>
              <ChevronLeft className="w-4 h-4 mr-1" /> {t('back')}
            </Button>
            <Button variant="primary" onClick={() => setStep('review')}>
              {t('next')} <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </Card>
      )}

      {/* Step: Review */}
      {step === 'review' && resolvedClient && (
        <Card>
          <h3 className="text-white font-semibold mb-4">{t('stepReviewTitle')}</h3>
          <div className="space-y-2 text-sm">
            <ReviewRow
              label={t('emailLabel')}
              value={resolvedClient.unregistered ? t('clientTypeUnregistered') : resolvedClient.email}
            />
            <ReviewRow label={t('titleLabel')} value={title} />
            <ReviewRow label={t('locationLabel')} value={location} />
            <ReviewRow label={t('budgetLabel')} value={`€ ${parseFloat(budget).toFixed(2)}`} />
            {deadline && <ReviewRow label={t('deadlineLabel')} value={deadline} />}
            {phases.filter((p) => p.name).length > 0 && (
              <div className="pt-2 border-t border-divider">
                <p className="text-text-secondary text-xs mb-1">{t('phasesLabel')}</p>
                {phases.filter((p) => p.name).map((p, i) => (
                  <p key={i} className="text-white">
                    {p.order}. {p.name} — € {parseFloat(p.amount || '0').toFixed(2)}
                  </p>
                ))}
              </div>
            )}
          </div>
          <div className="mt-6 flex flex-wrap justify-between gap-3">
            <Button variant="secondary" onClick={() => setStep('phases')}>
              <ChevronLeft className="w-4 h-4 mr-1" /> {t('back')}
            </Button>
            <div className="flex gap-2">
              <Button
                variant="secondary"
                onClick={() => handleSubmit(false)}
                disabled={createMut.isPending}
              >
                {t('saveDraft')}
              </Button>
              <Button
                variant="primary"
                onClick={() => handleSubmit(true)}
                disabled={createMut.isPending}
              >
                {createMut.isPending ? t('creating') : t('createAndSubmit')}
              </Button>
            </div>
          </div>
        </Card>
      )}
    </div>
  )
}

function ReviewRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex gap-2">
      <span className="text-text-secondary w-28 flex-shrink-0">{label}:</span>
      <span className="text-white">{value}</span>
    </div>
  )
}
