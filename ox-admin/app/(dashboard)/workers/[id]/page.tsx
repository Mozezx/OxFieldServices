'use client'
import { useParams } from 'next/navigation'
import { Header } from '@/components/layout/Header'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Skeleton } from '@/components/ui/Skeleton'
import { WorkerRatingStars } from '@/components/features/workers/WorkerRatingStars'
import { useWorker } from '@/lib/queries/useWorkers'
import { CheckCircle, XCircle, ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export default function WorkerDetailPage() {
  const { id } = useParams<{ id: string }>()
  const { data: worker, isLoading } = useWorker(id)

  if (isLoading) {
    return (
      <>
        <Header title="Worker" />
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
          <ArrowLeft className="w-4 h-4" /> Voltar
        </Link>

        {/* Header do perfil */}
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

        {/* Informações */}
        <Card>
          <h3 className="text-white font-semibold mb-4">Informações</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-text-secondary mb-1">Certificado NR-18</p>
              <div className="flex items-center gap-2">
                {worker.shelterCertified
                  ? <CheckCircle className="w-4 h-4 text-accent" />
                  : <XCircle className="w-4 h-4 text-error" />}
                <span className="text-white text-sm">{worker.shelterCertified ? 'Sim' : 'Não'}</span>
              </div>
            </div>
            <div>
              <p className="text-xs text-text-secondary mb-1">Disponível</p>
              <div className="flex items-center gap-2">
                {worker.available
                  ? <CheckCircle className="w-4 h-4 text-accent" />
                  : <XCircle className="w-4 h-4 text-error" />}
                <span className="text-white text-sm">{worker.available ? 'Sim' : 'Não'}</span>
              </div>
            </div>
          </div>
        </Card>

        {/* Skills */}
        <Card>
          <h3 className="text-white font-semibold mb-4">Skills</h3>
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
