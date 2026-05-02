'use client'
import { useState } from 'react'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { ProjectsTable } from '@/components/features/projects/ProjectsTable'
import { useProjects } from '@/lib/queries/useProjects'
import { Download } from 'lucide-react'

const statuses = [
  { value: '', label: 'Todos' },
  { value: 'draft', label: 'Rascunho' },
  { value: 'in_validation', label: 'Em Validação' },
  { value: 'in_execution', label: 'Em Execução' },
  { value: 'closing', label: 'Encerrando' },
  { value: 'closed', label: 'Concluído' },
  { value: 'rejected', label: 'Rejeitado' },
]

export default function ProjectsPage() {
  const [status, setStatus] = useState('')
  const [search, setSearch] = useState('')
  const { data: projects, isLoading } = useProjects(status || undefined)

  const filtered = projects?.filter((p) =>
    !search || p.title.toLowerCase().includes(search.toLowerCase()) ||
    p.client?.name?.toLowerCase().includes(search.toLowerCase()),
  )

  return (
    <>
      <Header title="Projetos" />
      <div className="p-6">
        <PageHeader
          title="Projetos"
          subtitle={`${filtered?.length ?? 0} projeto(s) encontrado(s)`}
          actions={
            <Button variant="secondary" size="sm">
              <Download className="w-4 h-4" /> Exportar CSV
            </Button>
          }
        />

        <Card className="mb-4">
          <div className="flex gap-4 flex-wrap items-end">
            <div className="flex-1 min-w-48">
              <Input
                label="Busca"
                placeholder="Título ou cliente..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-white">Status</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="bg-surface2 border border-divider rounded-input px-4 py-2.5 text-white focus:outline-none focus:border-accent"
              >
                {statuses.map((s) => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </div>
          </div>
        </Card>

        <Card padding={false}>
          <ProjectsTable projects={filtered} isLoading={isLoading} />
        </Card>
      </div>
    </>
  )
}
