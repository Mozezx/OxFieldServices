'use server'
import { createClient } from './supabase/server'
import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { cookies } from 'next/headers'
import { routing } from '@/i18n/routing'

async function cookieLocale() {
  const locale = (await cookies()).get('NEXT_LOCALE')?.value
  if (locale && routing.locales.includes(locale as (typeof routing.locales)[number])) {
    return locale
  }
  return routing.defaultLocale
}

export async function signIn(email: string, password: string) {
  const supabase = await createClient()
  const { error } = await supabase.auth.signInWithPassword({ email, password })
  if (error) return { error: error.message }
  revalidatePath('/', 'layout')
  redirect(`/${await cookieLocale()}/projects`)
}

export async function signOut() {
  const supabase = await createClient()
  await supabase.auth.signOut()
  revalidatePath('/', 'layout')
  redirect(`/${await cookieLocale()}/login`)
}

export async function getUser() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  return user
}
