import { NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

/**
 * Service Worker gerado com as mesmas variáveis NEXT_PUBLIC_FIREBASE_* do cliente.
 * Evita duplicar segredos à mão em public/ — as chaves Web já são públicas no Firebase.
 */
export async function GET() {
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY
  const authDomain = process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN ?? ''
  const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID
  const storageBucket = process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET ?? ''
  const messagingSenderId = process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID ?? ''
  const appId = process.env.NEXT_PUBLIC_FIREBASE_APP_ID ?? ''

  if (!apiKey || !projectId) {
    return new NextResponse(
      'console.error("[FCM SW] Defina NEXT_PUBLIC_FIREBASE_API_KEY e NEXT_PUBLIC_FIREBASE_PROJECT_ID no .env");',
      {
        status: 503,
        headers: {
          'Content-Type': 'application/javascript; charset=utf-8',
          'Cache-Control': 'no-store',
        },
      },
    )
  }

  const v = '12.12.1'
  const body = `importScripts('https://www.gstatic.com/firebasejs/${v}/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/${v}/firebase-messaging-compat.js')

firebase.initializeApp({
  apiKey: ${JSON.stringify(apiKey)},
  authDomain: ${JSON.stringify(authDomain)},
  projectId: ${JSON.stringify(projectId)},
  storageBucket: ${JSON.stringify(storageBucket)},
  messagingSenderId: ${JSON.stringify(messagingSenderId)},
  appId: ${JSON.stringify(appId)},
})

const messaging = firebase.messaging()

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? 'OX'
  const options = {
    body: payload.notification?.body ?? '',
    icon: '/favicon.ico',
    data: payload.data ?? {},
  }
  self.registration.showNotification(title, options)
})
`

  return new NextResponse(body, {
    headers: {
      'Content-Type': 'application/javascript; charset=utf-8',
      'Cache-Control': 'no-store, must-revalidate',
    },
  })
}
