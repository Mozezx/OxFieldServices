'use client'

import { initializeApp, getApps, type FirebaseApp } from 'firebase/app'
import {
  getMessaging,
  getToken,
  isSupported,
  onMessage,
  type Messaging,
} from 'firebase/messaging'
import type { MessagePayload } from 'firebase/messaging'

function firebaseConfig() {
  return {
    apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
    authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
    storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  }
}

export function getFirebaseApp(): FirebaseApp | null {
  if (typeof window === 'undefined') return null
  const cfg = firebaseConfig()
  if (!cfg.apiKey || !cfg.projectId) return null
  if (getApps().length) return getApps()[0]!
  return initializeApp(cfg)
}

export async function getMessagingIfSupported(): Promise<Messaging | null> {
  const supported = await isSupported().catch(() => false)
  if (!supported) return null
  const app = getFirebaseApp()
  if (!app) return null
  return getMessaging(app)
}

export type WebFcmRegisterResult =
  | { ok: true }
  | { ok: false; reason: 'insecure-context' | 'unsupported' | 'permission-denied' | 'missing-vapid' | 'no-token' | 'unknown'; detail?: string }

/**
 * Registra FCM web e envia token ao backend (plataforma web).
 * Push Web só funciona em contexto seguro: https:// ou http://localhost / http://127.0.0.1 — não em http://192.168.x.x.
 */
export async function registerWebFcmAndSync(
  postToken: (token: string) => Promise<void>,
): Promise<WebFcmRegisterResult> {
  if (typeof window !== 'undefined' && !window.isSecureContext) {
    console.warn(
      '[FCM Web] Push não está disponível: abre o admin em https:// ou http://localhost:<porta> (não use http://192.168… na rede local).',
    )
    return { ok: false, reason: 'insecure-context' }
  }

  const messaging = await getMessagingIfSupported()
  if (!messaging) {
    console.warn('[FCM Web] Firebase Messaging não suportado neste browser.')
    return { ok: false, reason: 'unsupported' }
  }

  const permission = await Notification.requestPermission()
  if (permission !== 'granted') {
    return { ok: false, reason: 'permission-denied' }
  }

  const vapidKey = (process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY ?? '').trim()
  if (!vapidKey) {
    console.error(
      '[FCM Web] Falta NEXT_PUBLIC_FIREBASE_VAPID_KEY — Firebase Console → Project settings → Cloud Messaging → Web Push certificates.',
    )
    return { ok: false, reason: 'missing-vapid' }
  }

  let registration: ServiceWorkerRegistration | undefined
  try {
    registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', {
      scope: '/',
    })
    await navigator.serviceWorker.ready
  } catch (e) {
    console.warn('[FCM Web] Service worker:', e)
  }

  try {
    const token = await getToken(messaging, {
      vapidKey,
      serviceWorkerRegistration: registration,
    })

    if (!token) {
      console.error('[FCM Web] getToken devolveu vazio.')
      return { ok: false, reason: 'no-token' }
    }

    await postToken(token)
    return { ok: true }
  } catch (e) {
    const detail = e instanceof Error ? e.message : String(e)
    console.error('[FCM Web] getToken falhou:', detail)
    return { ok: false, reason: 'unknown', detail }
  }
}

/** Escuta push com app em foreground (aba aberta). */
export function subscribeForegroundMessages(
  cb: (payload: MessagePayload) => void,
): () => void {
  let cancelled = false
  let off: (() => void) | undefined

  void getMessagingIfSupported().then((messaging) => {
    if (cancelled || !messaging) return
    off = onMessage(messaging, cb)
  })

  return () => {
    cancelled = true
    off?.()
  }
}
