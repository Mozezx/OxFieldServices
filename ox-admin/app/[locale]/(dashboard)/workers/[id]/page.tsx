'use client'

import { useParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'
import { Header } from '@/components/layout/Header'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { Skeleton } from '@/components/ui/Skeleton'
import { WorkerRatingStars } from '@/components/features/workers/WorkerRatingStars'
import { useWorker, useUpdateWorker } from '@/lib/queries/useWorkers'
import { CheckCircle, XCircle, ArrowLeft } from 'lucide-react'
import toast from 'react-hot-toast'

export default function WorkerDetailPage() {
  const { id } = useParams<{ id: string }>()
  const t = useTranslations('workerDetail')
  const tCommon = useTranslations('common')
  const { data: worker, isLoading } = useWorker(id)
  const updateWorker = useUpdateWorker(id)

  const handleToggleAvailable = () => {
    if (!worker) return
    const next = !worker.available
    updateWorker.mutate(
      { available: next },
      {
        onSuccess: () =>
          toast.success(next ? t('toastAvailable') : t('toastUnavailable')),
        onError: () => toast.error(t('toastError')),
      },
    )
  }

  if (isLoading) {
    return (
      <>
        <Header title={t('loadingTitle')} />
        <div className="p-6 space-y-4">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-48 w-full" />
        </div>
      </>
    )
  }

  if (!worker) return null

  return (
    <>
      <Header title={worker.user.name} />
      <div className="p-6 space-y-6 max-w-3xl">
        <Link href="/workers" className="inline-flex items-center gap-2 text-text-secondary hover:text-white text-sm">
          <ArrowLeft className="w-4 h-4" /> {t('back')}
        </Link>

        <Card>
          <div className="flex items-start gap-4">
            <div className="w-16 h-16 rounded-full bg-surface2 flex items-center justify-center text-accent text-2xl font-bold flex-shrink-0">
              {worker.user.name[0]}
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-bold text-white">{worker.user.name}</h2>
              <p className="text-text-secondary text-sm mb-2">{worker.user.email}</p>
              <WorkerRatingStars rating={Number(worker.rating)} />
            </div>
            <Badge status={worker.available ? 'available' : 'occupied'} />
          </div>
        </Card>

        <Card>
          <h3 className="text-white font-semibold mb-4">{t('info')}</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-text-secondary mb-1">{t('nr18')}</p>
              <div className="flex items-center gap-2">
                {worker.shelterCertified
                  ? <CheckCircle className="w-4 h-4 text-accent" />
                  : <XCircle className="w-4 h-4 text-error" />}
                <span className="text-white text-sm">{worker.shelterCertified ? tCommon('yes') : tCommon('no')}</span>
              </div>
            </div>
            <div>
              <p className="text-xs text-text-secondary mb-1">{t('available')}</p>
              <div className="flex items-center gap-2">
                {worker.available
                  ? <CheckCircle className="w-4 h-4 text-accent" />
                  : <XCircle className="w-4 h-4 text-error" />}
                <span className="text-white text-sm">{worker.available ? tCommon('yes') : tCommon('no')}</span>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 flex items-center justify-between gap-4">
            <div>
              <p className="text-sm text-white font-medium">
                {worker.available ? t('statusLineAvailable') : t('statusLineUnavailable')}
              </p>
              <p className="text-xs text-text-secondary mt-0.5">
                {worker.available ? t('availableHelpOn') : t('availableHelpOff')}
              </p>
            </div>
            <Button
              variant={worker.available ? 'secondary' : 'primary'}
              size="sm"
              isLoading={updateWorker.isPending}
              onClick={handleToggleAvailable}
            >
              {worker.available ? t('toggleAvailable') : t('toggleUnavailable')}
            </Button>
          </div>
        </Card>

        <Card>
          <h3 className="text-white font-semibold mb-4">{t('skills')}</h3>
          <div className="flex flex-wrap gap-2">
            {worker.skills.map((skill) => (
              <span key={skill} className="px-3 py-1 bg-accent/10 text-accent rounded-full text-sm">
                {skill}
              </span>
            ))}
          </div>
        </Card>
      </div>
    </>
  )
}
