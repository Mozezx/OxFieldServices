'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { WorkersTable } from '@/components/features/workers/WorkersTable'
import { useWorkers } from '@/lib/queries/useWorkers'

export default function WorkersPage() {
  const t = useTranslations('workers')
  const tCommon = useTranslations('common')
  const [search, setSearch] = useState('')
  const { data: workers, isLoading } = useWorkers()

  const filtered = workers?.filter((w) =>
    !search ||
    w.user.name.toLowerCase().includes(search.toLowerCase()) ||
    w.skills.some((s) => s.toLowerCase().includes(search.toLowerCase())),
  )

  const count = filtered?.length ?? 0

  return (
    <>
      <Header title={t('title')} />
      <div className="p-6">
        <PageHeader
          title={t('title')}
          subtitle={t('subtitleCount', { count })}
        />

        <Card className="mb-4">
          <Input
            label={tCommon('search')}
            placeholder={t('searchPlaceholder')}
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
