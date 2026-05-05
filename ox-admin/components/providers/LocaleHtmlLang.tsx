'use client'

import { useLocale } from 'next-intl'
import { useEffect } from 'react'

/** Syncs `<html lang>` with the active locale (root layout keeps a static default for SSG). */
export function LocaleHtmlLang() {
  const locale = useLocale()

  useEffect(() => {
    document.documentElement.lang = locale
  }, [locale])

  return null
}
