'use client'

import { useLocale, useTranslations } from 'next-intl'
import { Globe } from 'lucide-react'
import { usePathname, useRouter } from '@/i18n/navigation'
import { routing } from '@/i18n/routing'
import api from '@/lib/api'

const shortLabels: Record<string, string> = {
  en: 'English',
  nl: 'Nederlands',
  es: 'Español',
  pt: 'Português',
}

export function LanguageSwitcher() {
  const t = useTranslations('header')
  const locale = useLocale()
  const router = useRouter()
  const pathname = usePathname()

  return (
    <div className="flex items-center gap-2">
      <Globe className="h-4 w-4 shrink-0 text-text-secondary" aria-hidden />
      <label className="sr-only" htmlFor="locale-switcher">
        {t('language')}
      </label>
      <select
        id="locale-switcher"
        value={locale}
        aria-label={t('language')}
        onChange={async (e) => {
          const next = e.target.value as (typeof routing.locales)[number]
          try {
            await api.patch('/users/preferred-locale', {
              preferredLocale: next,
            })
          } catch {
            /* ignore — sem sessão ou backend indisponível */
          }
          router.replace(pathname, { locale: next })
        }}
        className="rounded-lg border border-divider bg-surface2 px-2 py-1.5 text-sm text-white focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"
      >
        {routing.locales.map((loc) => (
          <option key={loc} value={loc}>
            {shortLabels[loc] ?? loc.toUpperCase()}
          </option>
        ))}
      </select>
    </div>
  )
}
