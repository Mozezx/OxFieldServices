'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Modal } from '@/components/ui/Modal'
import { ProjectsTable } from '@/components/features/projects/ProjectsTable'
import { CreateProjectForm } from '@/components/features/projects/CreateProjectForm'
import { useProjects } from '@/lib/queries/useProjects'
import { useAuthMe } from '@/lib/queries/useAuthMe'
import { Download, PlusCircle } from 'lucide-react'

export default function ProjectsPage() {
  const t = useTranslations('projects')
  const tCommon = useTranslations('common')
  const tNav = useTranslations('nav')
  const tCreate = useTranslations('createProject')
  const [status, setStatus] = useState('')
  const [search, setSearch] = useState('')
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)
  const { data: me } = useAuthMe()
  const { data: projects, isLoading } = useProjects(status || undefined)

  const filtered = projects?.filter((p) =>
    !search || p.title.toLowerCase().includes(search.toLowerCase()) ||
    p.client?.name?.toLowerCase().includes(search.toLowerCase()),
  )

  const statuses = [
    { value: '', label: t('statusFilter.all') },
    { value: 'draft', label: t('statusFilter.draft') },
    { value: 'matched', label: t('statusFilter.matched') },
    { value: 'contract_signed', label: t('statusFilter.contract_signed') },
    { value: 'active_escrow', label: t('statusFilter.active_escrow') },
    { value: 'in_execution', label: t('statusFilter.in_execution') },
    { value: 'closing', label: t('statusFilter.closing') },
    { value: 'closed', label: t('statusFilter.closed') },
    { value: 'rejected', label: t('statusFilter.rejected') },
  ]

  const count = filtered?.length ?? 0

  return (
    <>
      <Header title={t('title')} />
      <div className="p-6">
        {me?.role === 'client' ? (
          <div className="mb-4 rounded-lg border border-warning/35 bg-warning/10 px-4 py-3 text-sm text-warning">
            {t.rich('bannerClient', {
              strong: (chunks) => <strong>{chunks}</strong>,
              code: (chunks) => <code className="text-xs">{chunks}</code>,
            })}
          </div>
        ) : null}
        {me?.role === 'worker' ? (
          <div className="mb-4 rounded-lg border border-warning/35 bg-warning/10 px-4 py-3 text-sm text-warning">
            {t.rich('bannerWorker', {
              strong: (chunks) => <strong>{chunks}</strong>,
            })}
          </div>
        ) : null}
        <PageHeader
          title={t('title')}
          subtitle={t('subtitleCount', { count })}
          actions={
            <div className="flex items-center gap-2">
              <Button
                variant="primary"
                size="sm"
                onClick={() => setIsCreateModalOpen(true)}
              >
                <PlusCircle className="w-4 h-4" /> {tNav('newProject')}
              </Button>
              <Button variant="secondary" size="sm">
                <Download className="w-4 h-4" /> {t('exportCsv')}
              </Button>
            </div>
          }
        />
        <Modal
          isOpen={isCreateModalOpen}
          onClose={() => setIsCreateModalOpen(false)}
          title={tCreate('pageTitle')}
          className="max-w-2xl w-[95vw] max-h-[90vh] overflow-y-auto"
        >
          <CreateProjectForm />
        </Modal>

        <Card className="mb-4">
          <div className="flex gap-4 flex-wrap items-end">
            <div className="flex-1 min-w-48">
              <Input
                label={tCommon('search')}
                placeholder={t('searchPlaceholder')}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-white">{tCommon('status')}</label>
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
