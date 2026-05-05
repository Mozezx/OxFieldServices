import createMiddleware from 'next-intl/middleware'
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { routing } from './i18n/routing'

const intlMiddleware = createMiddleware(routing)

function stripLocale(pathname: string): { locale: string; pathWithoutLocale: string } {
  const segments = pathname.split('/').filter(Boolean)
  const first = segments[0]
  if (routing.locales.includes(first as (typeof routing.locales)[number])) {
    return {
      locale: first,
      pathWithoutLocale: '/' + segments.slice(1).join('/') || '/',
    }
  }
  return { locale: routing.defaultLocale, pathWithoutLocale: pathname }
}

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname

  if (pathname.startsWith('/firebase-messaging-sw')) {
    return NextResponse.next()
  }

  const response = intlMiddleware(request)

  if (response.status >= 300 && response.status < 400) {
    return response
  }

  const { pathWithoutLocale } = stripLocale(pathname)

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet: { name: string; value: string; options?: Record<string, unknown> }[]) {
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options)
          })
        },
      },
    },
  )

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const isAuthPage = pathWithoutLocale === '/login' || pathWithoutLocale.startsWith('/login')
  const isPublic = isAuthPage || pathWithoutLocale === '/'

  if (!user && !isPublic) {
    const url = request.nextUrl.clone()
    const { locale } = stripLocale(pathname)
    url.pathname = `/${locale}/login`
    return NextResponse.redirect(url)
  }

  if (user && isAuthPage) {
    const url = request.nextUrl.clone()
    const { locale } = stripLocale(pathname)
    url.pathname = `/${locale}/projects`
    return NextResponse.redirect(url)
  }

  return response
}

export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico|firebase-messaging-sw|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
