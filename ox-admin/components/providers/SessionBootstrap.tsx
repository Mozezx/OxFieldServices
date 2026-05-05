'use client'

import { useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import api from '@/lib/api'
import { createClient } from '@/lib/supabase/client'

const storageKeyFor = (authUserId: string) => `ox-admin-auth-sync:${authUserId}`

/**
 * Utilizador autenticado no Supabase mas sem linha em public."User" recebe
 * `{ _unsynced: true }` no JWT — sem `role`, o RolesGuard devolve 403 em /projects.
 * Corremos POST /auth/sync uma vez por utilizador (DTO só permite client/worker).
 * Contas administrativas devem existir já em BD com role admin.
 */
export function SessionBootstrap() {
  const qc = useQueryClient()

  useEffect(() => {
    let cancelled = false

    ;(async () => {
      const supabase = createClient()
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (!session || cancelled) return

      const uid = session.user.id
      if (typeof window !== 'undefined' && sessionStorage.getItem(storageKeyFor(uid))) {
        return
      }

      try {
        const { data: me } = await api.get<{
          _unsynced?: boolean
          role?: string
          email?: string
        }>('/auth/me')
        if (cancelled || !me) return

        const needsSync = Boolean(me._unsynced) || !me.role
        if (!needsSync) return

        const metaName = session.user.user_metadata?.full_name
        const email = session.user.email ?? me.email ?? 'sync@local'
        const local = email.split('@')[0] ?? 'user'
        const name =
          typeof metaName === 'string' && metaName.trim().length >= 2
            ? metaName.trim()
            : local.length >= 2
              ? local
              : 'Utilizador'

        await api.post('/auth/sync', { name, role: 'client' })
        if (typeof window !== 'undefined') sessionStorage.setItem(storageKeyFor(uid), '1')
        await qc.invalidateQueries({ queryKey: ['auth', 'me'] })
        await qc.invalidateQueries({ queryKey: ['projects'] })
      } catch {
        // Falha silenciosa; 403 continuará até sync manual ou seed correto.
      }
    })()

    return () => {
      cancelled = true
    }
  }, [qc])

  return null
}
