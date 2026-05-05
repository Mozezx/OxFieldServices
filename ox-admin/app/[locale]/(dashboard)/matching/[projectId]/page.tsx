'use client'

import { useParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'
import { Header } from '@/components/layout/Header'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Skeleton } from '@/components/ui/Skeleton'
import { CandidatesCard } from '@/components/features/matching/CandidatesCard'
import { useProject } from '@/lib/queries/useProjects'
import { useCandidates } from '@/lib/queries/useWorkers'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import { ArrowLeft, MapPin, AlertTriangle, Repeat } from 'lucide-react'

export default function MatchingPage() {
  const { projectId } = useParams<{ projectId: string }>()
  const t = useTranslations('matching')
  const { data: project, isLoading: projectLoading } = useProject(projectId)
  const { data: candidates, isLoading: candidatesLoading } = useCandidates(projectId)

  const contract = project?.contract
  const isFirstAssign = project?.status === 'matched' && !contract
  const isSwap =
    project?.status === 'contract_signed' &&
    !!contract &&
    !contract.signedAt &&
    !contract.escrow
  const canOperate = isFirstAssign || isSwap

  const blockerReason = (() => {
    if (!project) return null
    if (canOperate) return null
    if (project.status === 'draft') {
      return t('reasonDraft')
    }
    if (project.status === 'contract_signed' && contract?.signedAt) {
      return t('reasonSigned')
    }
    if (project.status === 'contract_signed' && contract?.escrow) {
      return t('reasonEscrow')
    }
    return t('reasonGeneric', { status: project.status })
  })()

  return (
    <>
      <Header title={t('title')} />
      <div className="p-6">
        <Link href={`/projects/${projectId}`} className="inline-flex items-center gap-2 text-text-secondary hover:text-white text-sm mb-6">
          <ArrowLeft className="w-4 h-4" /> {t('backToProject')}
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h2 className="text-white font-semibold mb-3">{t('projectSection')}</h2>
            {projectLoading ? (
              <Skeleton className="h-48 w-full rounded-card" />
            ) : project && (
              <Card>
                <div className="flex items-start justify-between mb-3">
                  <h3 className="text-white font-bold">{project.title}</h3>
                  <Badge status={project.status} />
                </div>
                {project.location && (
                  <p className="text-text-secondary text-sm flex items-center gap-1 mb-2">
                    <MapPin className="w-4 h-4" /> {project.location}
                  </p>
                )}
                <p className="text-accent font-semibold">{formatCurrency(Number(project.budget))}</p>

                {contract && (
                  <div className="mt-4 pt-4 border-t border-divider">
                    <p className="text-xs text-text-secondary mb-1">{t('currentWorker')}</p>
                    <p className="text-white font-medium">
                      {contract.worker?.user?.name ?? '—'}
                    </p>
                    <p className="text-xs text-text-disabled mt-1">
                      {contract.signedAt
                        ? t('contractSignedShort')
                        : contract.escrow
                          ? t('escrowActiveShort')
                          : t('awaitingSwap')}
                    </p>
                  </div>
                )}

                {project.phases && project.phases.length > 0 && (
                  <div className="mt-4 pt-4 border-t border-divider">
                    <p className="text-xs text-text-secondary mb-2">{t('requiredSkills')}</p>
                    <div className="flex flex-wrap gap-1.5">
                      {Array.from(new Set(project.phases.map((p) => p.name))).map((skill) => (
                        <span key={skill} className="text-xs bg-surface2 text-text-secondary px-2 py-0.5 rounded-full">
                          {skill}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </Card>
            )}
          </div>

          <div>
            <h2 className="text-white font-semibold mb-3">
              {isSwap ? t('swapTitle') : t('candidatesTitle')}{' '}
              {candidates ? `(${candidates.length})` : ''}
            </h2>

            {project && isSwap && (
              <Card className="mb-3 border-accent/40 bg-accent/5">
                <div className="flex gap-3">
                  <Repeat className="w-5 h-5 text-accent shrink-0 mt-0.5" />
                  <div className="text-sm">
                    <p className="text-accent font-medium mb-1">{t('swapModeTitle')}</p>
                    <p className="text-text-secondary">
                      {t('swapModeBody', {
                        name: contract?.worker?.user?.name ?? t('currentWorkerFallback'),
                      })}
                    </p>
                  </div>
                </div>
              </Card>
            )}

            {project && !canOperate && blockerReason && (
              <Card className="mb-3 border-amber-500/40 bg-amber-500/5">
                <div className="flex gap-3">
                  <AlertTriangle className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
                  <div className="text-sm">
                    <p className="text-amber-200 font-medium mb-1">
                      {t('assignmentBlocked')}
                    </p>
                    <p className="text-text-secondary">{blockerReason}</p>
                    <Link
                      href={`/projects/${project.id}`}
                      className="inline-block mt-2 text-amber-300 hover:text-amber-200 underline text-xs"
                    >
                      {t('goToProject')}
                    </Link>
                  </div>
                </div>
              </Card>
            )}

            {candidatesLoading ? (
              <div className="space-y-3">
                {[1, 2, 3].map((i) => <Skeleton key={i} className="h-32 w-full rounded-card" />)}
              </div>
            ) : candidates && candidates.length > 0 ? (
              <CandidatesCard
                projectId={projectId}
                candidates={candidates}
                currentWorkerName={isSwap ? contract?.worker?.user?.name ?? null : null}
                disabled={!canOperate}
              />
            ) : (
              <Card>
                <p className="text-text-secondary text-center py-8">
                  {t('noCandidates')}
                </p>
              </Card>
            )}
          </div>
        </div>
      </div>
    </>
  )
}
