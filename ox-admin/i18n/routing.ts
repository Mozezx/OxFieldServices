import { defineRouting } from 'next-intl/routing'

export const routing = defineRouting({
  locales: ['en', 'nl', 'es', 'pt'],
  defaultLocale: 'en',
  localePrefix: 'always',
})
