'use client'

import { useParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'
import { Header } from '@/components/layout/Header'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { Skeleton } from '@/components/ui/Skeleton'
import {
  ProjectStatusSelect,
  hasStatusTransitions,
} from '@/components/features/projects/ProjectStatusSelect'
import { PhaseTimeline } from '@/components/features/projects/PhaseTimeline'
import { InvitePanel } from '@/components/features/projects/InvitePanel'
import { useProject } from '@/lib/queries/useProjects'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import { formatDate } from '@/lib/utils/formatDate'
import { ArrowLeft, MapPin, Calendar, DollarSign, Users, Plus } from 'lucide-react'

export default function ProjectDetailPage() {
  const { id } = useParams<{ id: string }>()
  const t = useTranslations('projectDetail')
  const tCommon = useTranslations('common')
  const { data: project, isLoading } = useProject(id)

  if (isLoading) {
    return (
      <>
        <Header title={t('loadingTitle')} />
        <div className="p-6 space-y-4">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-48 w-full" />
          <Skeleton className="h-64 w-full" />
        </div>
      </>
    )
  }

  if (!project) return null

  const contract = project.contract
  const canAssign = project.status === 'matched'
  const canSwap =
    project.status === 'contract_signed' &&
    !!contract &&
    !contract.signedAt &&
    !contract.escrow
  const showMatchingAction = canAssign || canSwap
  const hasAnyAction = hasStatusTransitions(project.status) || showMatchingAction

  return (
    <>
      <Header title={project.title} />
      <div className="p-6 space-y-6 max-w-4xl mx-auto">
        <Link href="/projects" className="inline-flex items-center gap-2 text-text-secondary hover:text-white text-sm">
          <ArrowLeft className="w-4 h-4" /> {t('back')}
        </Link>

        <Card>
          <div className="flex items-start justify-between flex-wrap gap-4 mb-4">
            <div>
              <h2 className="text-xl font-bold text-white mb-1">{project.title}</h2>
              <div className="flex items-center gap-4 text-sm text-text-secondary flex-wrap">
                {project.location && (
                  <span className="flex items-center gap-1">
                    <MapPin className="w-4 h-4" /> {project.location}
                  </span>
                )}
                {project.deadline && (
                  <span className="flex items-center gap-1">
                    <Calendar className="w-4 h-4" /> {formatDate(project.deadline)}
                  </span>
                )}
                <span className="flex items-center gap-1">
                  <DollarSign className="w-4 h-4" /> {formatCurrency(Number(project.budget))}
                </span>
              </div>
            </div>
            <Badge status={project.status} />
          </div>

          <div className="pt-4 border-t border-divider">
            <p className="text-xs text-text-secondary mb-1">{tCommon('client')}</p>
            <p className="text-white font-medium">{project.client?.name}</p>
            <p className="text-text-secondary text-sm">{project.client?.email}</p>
          </div>

          {contract && (
            <div className="pt-4 mt-4 border-t border-divider">
              <p className="text-xs text-text-secondary mb-1">{t('assignedWorker')}</p>
              <p className="text-white font-medium">
                {contract.worker?.user?.name ?? '—'}
              </p>
              <p className="text-xs text-text-disabled mt-1">
                {contract.signedAt
                  ? t('contractSigned')
                  : contract.escrow
                    ? t('escrowActive')
                    : t('awaitingSignature')}
              </p>
            </div>
          )}

          <div className="pt-4 mt-4 border-t border-divider">
            <p className="text-sm font-medium text-text-secondary mb-3">
              {t('availableActions')}
            </p>
            {hasAnyAction ? (
              <div className="flex flex-wrap items-center gap-2">
                <ProjectStatusSelect
                  projectId={project.id}
                  currentStatus={project.status}
                />
                {showMatchingAction && (
                  <Link href={`/matching/${project.id}`}>
                    <Button variant="primary" size="sm">
                      <Users className="w-4 h-4" />
                      {canSwap
                        ? t('swapWorker')
                        : t('viewCandidates')}
                    </Button>
                  </Link>
                )}
                <div className="ml-auto">
                  <InvitePanel projectId={project.id} clientPhone={null} compact />
                </div>
              </div>
            ) : (
              <p className="text-sm text-text-disabled">
                {t('noActions')}
              </p>
            )}
          </div>
        </Card>

        {project.phases && project.phases.length > 0 && (
          <Card>
            <h3 className="text-white font-semibold mb-4">{t('phasesTitle')}</h3>
            <PhaseTimeline phases={project.phases} />
          </Card>
        )}

      </div>
    </>
  )
}
