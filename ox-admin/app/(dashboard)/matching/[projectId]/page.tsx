'use client'
import { useParams } from 'next/navigation'
import { Header } from '@/components/layout/Header'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Skeleton } from '@/components/ui/Skeleton'
import { CandidatesCard } from '@/components/features/matching/CandidatesCard'
import { useProject } from '@/lib/queries/useProjects'
import { useCandidates } from '@/lib/queries/useWorkers'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import { ArrowLeft, MapPin, AlertTriangle, Repeat } from 'lucide-react'
import Link from 'next/link'

export default function MatchingPage() {
  const { projectId } = useParams<{ projectId: string }>()
  const { data: project, isLoading: projectLoading } = useProject(projectId)
  const { data: candidates, isLoading: candidatesLoading } = useCandidates(projectId)

  // Decide se a tela permite atribuir/trocar
  const contract = project?.contract
  const isFirstAssign = project?.status === 'matched' && !contract
  const isSwap =
    project?.status === 'contract_signed' &&
    !!contract &&
    !contract.signedAt &&
    !contract.escrow
  const canOperate = isFirstAssign || isSwap

  // Mensagem do banner quando não dá pra operar (ou contexto da troca)
  const blockerReason = (() => {
    if (!project) return null
    if (canOperate) return null
    if (project.status === 'draft') {
      return 'O cliente precisa submeter o projeto para validação primeiro.'
    }
    if (project.status === 'in_validation') {
      return 'Aprove o projeto na tela de detalhes antes de atribuir um worker.'
    }
    if (project.status === 'contract_signed' && contract?.signedAt) {
      return 'O contrato já foi assinado pelo worker, não é possível trocar.'
    }
    if (project.status === 'contract_signed' && contract?.escrow) {
      return 'Já existe escrow ativo, não é possível trocar de worker.'
    }
    return `Status atual: ${project.status}. Atribuição não disponível neste estado.`
  })()

  return (
    <>
      <Header title="Matching" />
      <div className="p-6">
        <Link href={`/projects/${projectId}`} className="inline-flex items-center gap-2 text-text-secondary hover:text-white text-sm mb-6">
          <ArrowLeft className="w-4 h-4" /> Voltar ao projeto
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Projeto */}
          <div>
            <h2 className="text-white font-semibold mb-3">Projeto</h2>
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

                {/* Worker atual (se já houver contrato) */}
                {contract && (
                  <div className="mt-4 pt-4 border-t border-divider">
                    <p className="text-xs text-text-secondary mb-1">Worker atual</p>
                    <p className="text-white font-medium">
                      {contract.worker?.user?.name ?? '—'}
                    </p>
                    <p className="text-xs text-text-disabled mt-1">
                      {contract.signedAt
                        ? 'Contrato assinado'
                        : contract.escrow
                          ? 'Escrow ativo'
                          : 'Aguardando assinatura — pode ser trocado'}
                    </p>
                  </div>
                )}

                {project.phases && project.phases.length > 0 && (
                  <div className="mt-4 pt-4 border-t border-divider">
                    <p className="text-xs text-text-secondary mb-2">Skills necessárias</p>
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

          {/* Candidatos */}
          <div>
            <h2 className="text-white font-semibold mb-3">
              {isSwap ? 'Trocar worker' : 'Candidatos'}{' '}
              {candidates ? `(${candidates.length})` : ''}
            </h2>

            {/* Banner: troca em andamento (informativo) */}
            {project && isSwap && (
              <Card className="mb-3 border-accent/40 bg-accent/5">
                <div className="flex gap-3">
                  <Repeat className="w-5 h-5 text-accent shrink-0 mt-0.5" />
                  <div className="text-sm">
                    <p className="text-accent font-medium mb-1">Modo troca de worker</p>
                    <p className="text-text-secondary">
                      O contrato atual com{' '}
                      <span className="text-white">
                        {contract?.worker?.user?.name ?? 'worker atual'}
                      </span>{' '}
                      será substituído ao confirmar.
                    </p>
                  </div>
                </div>
              </Card>
            )}

            {/* Banner: bloqueio (status errado ou contrato já assinado/pago) */}
            {project && !canOperate && blockerReason && (
              <Card className="mb-3 border-amber-500/40 bg-amber-500/5">
                <div className="flex gap-3">
                  <AlertTriangle className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
                  <div className="text-sm">
                    <p className="text-amber-200 font-medium mb-1">
                      Atribuição não disponível
                    </p>
                    <p className="text-text-secondary">{blockerReason}</p>
                    <Link
                      href={`/projects/${project.id}`}
                      className="inline-block mt-2 text-amber-300 hover:text-amber-200 underline text-xs"
                    >
                      Ir para o projeto
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
                  Nenhum candidato disponível para este projeto.
                </p>
              </Card>
            )}
          </div>
        </div>
      </div>
    </>
  )
}
