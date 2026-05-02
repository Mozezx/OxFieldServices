'use client'
import { useState } from 'react'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { WorkersTable } from '@/components/features/workers/WorkersTable'
import { useWorkers } from '@/lib/queries/useWorkers'

export default function WorkersPage() {
  const [search, setSearch] = useState('')
  const { data: workers, isLoading } = useWorkers()

  const filtered = workers?.filter((w) =>
    !search ||
    w.user.name.toLowerCase().includes(search.toLowerCase()) ||
    w.skills.some((s) => s.toLowerCase().includes(search.toLowerCase())),
  )

  return (
    <>
      <Header title="Workers" />
      <div className="p-6">
        <PageHeader
          title="Workers"
          subtitle={`${filtered?.length ?? 0} trabalhador(es)`}
        />

        <Card className="mb-4">
          <Input
            label="Busca"
            placeholder="Nome ou skill..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </Card>

        <Card padding={false}>
          <WorkersTable workers={filtered} isLoading={isLoading} />
        </Card>
      </div>
    </>
  )
}
