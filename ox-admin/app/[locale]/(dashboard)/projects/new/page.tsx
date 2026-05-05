'use client'

import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'
import { ArrowLeft } from 'lucide-react'
import { Header } from '@/components/layout/Header'
import { CreateProjectForm } from '@/components/features/projects/CreateProjectForm'

export default function NewProjectPage() {
  const t = useTranslations('createProject')

  return (
    <>
      <Header title={t('pageTitle')} />
      <div className="p-6">
        <Link href="/projects" className="inline-flex items-center gap-2 text-text-secondary hover:text-white text-sm mb-6">
          <ArrowLeft className="w-4 h-4" /> {t('back')}
        </Link>
        <CreateProjectForm />
      </div>
    </>
  )
}
