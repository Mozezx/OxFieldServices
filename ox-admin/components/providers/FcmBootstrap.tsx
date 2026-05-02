'use client'

import { useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import {
  getFirebaseApp,
  subscribeForegroundMessages,
  registerWebFcmAndSync,
} from '@/lib/firebase/messaging'

/**
 * Registra token web + refresh das queries quando chega push em foreground.
 */
export function FcmBootstrap() {
  const queryClient = useQueryClient()

  useEffect(() => {
    if (!getFirebaseApp()) return

    let unsubscribe: (() => void) | undefined
    let cancelled = false

    ;(async () => {
      try {
        const reg = await registerWebFcmAndSync(async (token) => {
          await api.post('/users/device-tokens', {
            token,
            platform: 'web',
          })
        })
        if (!reg.ok && reg.reason === 'insecure-context') {
          toast.error(
            'Push no browser: usa https:// ou http://localhost (endereço IP da rede local não recebe FCM).',
            { duration: 10_000, id: 'fcm-insecure' },
          )
        } else if (!reg.ok && reg.reason === 'missing-vapid') {
          toast.error('FCM Web: falta NEXT_PUBLIC_FIREBASE_VAPID_KEY no .env do admin.', {
            duration: 10_000,
            id: 'fcm-vapid',
          })
        } else if (!reg.ok && reg.reason === 'unknown' && reg.detail) {
          console.warn('[FCM] detalhe:', reg.detail)
        }
      } catch (e) {
        console.warn('[FCM] registo no servidor falhou:', e)
      }

      if (cancelled) return

      unsubscribe = subscribeForegroundMessages((payload) => {
        const title = payload.notification?.title ?? 'OX'
        const body = payload.notification?.body ?? ''
        toast.custom(
          (t) => (
            <div
              className="rounded-lg border border-divider bg-surface1 px-4 py-3 text-sm text-white shadow-lg max-w-sm"
              onClick={() => toast.dismiss(t.id)}
            >
              <p className="font-semibold">{title}</p>
              {body ? <p className="mt-1 text-text-secondary">{body}</p> : null}
            </div>
          ),
          { duration: 6_000 },
        )
        queryClient.invalidateQueries({ queryKey: ['notifications'] })
      })
    })()

    return () => {
      cancelled = true
      unsubscribe?.()
    }
  }, [queryClient])

  return null
}
