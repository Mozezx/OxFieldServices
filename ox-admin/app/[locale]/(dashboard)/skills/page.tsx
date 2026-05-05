'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Input } from '@/components/ui/Input'
import { Trash2, Plus, Loader2 } from 'lucide-react'
import { useSkills, useCreateSkill, useDeleteSkill } from '@/lib/queries/useSkills'

export default function SkillsPage() {
  const t = useTranslations('skills')
  const tCommon = useTranslations('common')
  const { data: skills, isLoading } = useSkills()
  const createSkill = useCreateSkill()
  const deleteSkill = useDeleteSkill()

  const [label, setLabel] = useState('')
  const [name, setName] = useState('')
  const [error, setError] = useState('')

  function handleLabelChange(value: string) {
    setLabel(value)
    setName(value.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, ''))
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    setError('')
    if (!label.trim() || !name.trim()) return
    try {
      await createSkill.mutateAsync({ name, label: label.trim() })
      setLabel('')
      setName('')
    } catch (err: unknown) {
      const ax = err as { response?: { data?: { message?: string } } }
      setError(ax?.response?.data?.message ?? t('createError'))
    }
  }

  async function handleDelete(id: string) {
    await deleteSkill.mutateAsync(id)
  }

  const count = skills?.length ?? 0

  return (
    <>
      <Header title={t('title')} />
      <div className="p-6 space-y-6 max-w-2xl">
        <PageHeader
          title={t('pageTitle')}
          subtitle={t('subtitle')}
        />

        <Card>
          <h3 className="text-white font-semibold mb-4">{t('newTitle')}</h3>
          <form onSubmit={handleCreate} className="space-y-4">
            <div>
              <Input
                label={t('displayName')}
                placeholder={t('displayPlaceholder')}
                value={label}
                onChange={(e) => handleLabelChange(e.target.value)}
              />
            </div>
            <div>
              <label className="block text-xs text-text-secondary mb-1 font-medium">{t('internalKey')}</label>
              <div className="px-3 py-2 rounded-lg bg-primary border border-divider text-text-secondary text-sm font-mono">
                {name || tCommon('dash')}
              </div>
            </div>
            {error && <p className="text-error text-sm">{error}</p>}
            <button
              type="submit"
              disabled={!label.trim() || createSkill.isPending}
              className="flex items-center gap-2 px-4 py-2 rounded-lg bg-accent text-primary text-sm font-semibold disabled:opacity-40 hover:opacity-90 transition-opacity"
            >
              {createSkill.isPending
                ? <Loader2 className="w-4 h-4 animate-spin" />
                : <Plus className="w-4 h-4" />}
              {t('add')}
            </button>
          </form>
        </Card>

        <Card padding={false}>
          <div className="px-6 py-4 border-b border-divider">
            <span className="text-white font-semibold">
              {isLoading ? tCommon('loadingShort') : t('count', { count })}
            </span>
          </div>
          {isLoading ? (
            <div className="p-6 text-text-secondary text-sm">{t('loading')}</div>
          ) : skills?.length === 0 ? (
            <div className="p-6 text-text-secondary text-sm">{t('empty')}</div>
          ) : (
            <ul className="divide-y divide-divider">
              {skills?.map((skill) => (
                <li key={skill.id} className="flex items-center justify-between px-6 py-3">
                  <div>
                    <span className="text-white text-sm font-medium">{skill.label}</span>
                    <span className="ml-2 text-text-secondary text-xs font-mono">{skill.name}</span>
                  </div>
                  <button
                    type="button"
                    onClick={() => handleDelete(skill.id)}
                    disabled={deleteSkill.isPending}
                    className="text-text-secondary hover:text-error transition-colors disabled:opacity-40"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </>
  )
}
