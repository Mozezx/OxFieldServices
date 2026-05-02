import type { Metadata } from 'next'
import { Toaster } from 'react-hot-toast'
import { QueryProvider } from '@/components/providers/QueryProvider'
import './globals.css'

export const metadata: Metadata = {
  title: 'OX Admin Panel',
  description: 'Painel administrativo OX Field Services',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt">
      <body>
        <QueryProvider>
          {children}
          <Toaster
            position="top-right"
            toastOptions={{
              style: {
                background: '#0D3F52',
                color: '#fff',
                border: '1px solid #1A5570',
                borderRadius: '12px',
              },
            }}
          />
        </QueryProvider>
      </body>
    </html>
  )
}
