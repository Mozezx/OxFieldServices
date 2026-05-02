'use client'

import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import {
  useMarkAllNotificationsRead,
  useMarkNotificationRead,
  useNotificationsList,
} from '@/lib/queries/useNotifications'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleString('pt-BR')
  } catch {
    return iso
  }
}

export default function NotificationsPage() {
  const router = useRouter()
  const { data, isLoading, error, refetch } = useNotificationsList()
  const markRead = useMarkNotificationRead()
  const markAll = useMarkAllNotificationsRead()

  const items = data?.items ?? []

  function hrefFor(n: {
    entityType: string | null
    entityId: string | null
    data?: Record<string, unknown> | null
  }) {
    switch (n.entityType) {
      case 'project':
        return n.entityId ? `/projects/${n.entityId}` : null
      case 'phase': {
        const pid = n.data?.projectId
        return typeof pid === 'string' ? `/projects/${pid}` : null
      }
      case 'contract':
      case 'escrow':
      case 'payment':
        return '/payments'
      case 'worker':
        return n.entityId ? `/workers/${n.entityId}` : null
      default:
        return null
    }
  }

  return (
    <div className="flex flex-col min-h-full">
      <Header title="Notificações" />
      <div className="p-6 flex-1">
        <div className="flex items-start justify-between gap-4 mb-6">
          <PageHeader
            title="Central de notificações"
            subtitle="Alertas de projetos, fases e pagamentos"
          />
          <button
            type="button"
            onClick={() => markAll.mutate()}
            disabled={markAll.isPending || items.length === 0}
            className="rounded-lg bg-accent px-4 py-2 text-sm font-medium text-primary hover:opacity-90 disabled:opacity-40"
          >
            Marcar todas como lidas
          </button>
        </div>

        {isLoading ? (
          <p className="text-text-secondary">Carregando…</p>
        ) : error ? (
          <p className="text-red-400">Erro ao carregar notificações.</p>
        ) : items.length === 0 ? (
          <p className="text-text-secondary">Nenhuma notificação.</p>
        ) : (
          <ul className="space-y-2">
            {items.map((n) => {
              const href = hrefFor(n)
              const unread = !n.readAt
              return (
                <li
                  key={n.id}
                  className={`rounded-xl border border-divider bg-surface1 px-4 py-3 ${
                    unread ? 'border-accent/40' : ''
                  }`}
                >
                  <button
                    type="button"
                    className="w-full text-left"
                    onClick={() => {
                      if (unread) markRead.mutate(n.id)
                      const link = hrefFor(n)
                      if (link) router.push(link)
                    }}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p
                          className={`font-medium ${unread ? 'text-white' : 'text-text-secondary'}`}
                        >
                          {n.title}
                        </p>
                        <p className="mt-1 text-sm text-text-secondary">{n.body}</p>
                        <p className="mt-2 text-xs text-text-secondary/70">
                          {formatDate(n.createdAt)}
                        </p>
                      </div>
                      {unread ? (
                        <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-accent" />
                      ) : null}
                    </div>
                    {href ? (
                      <p className="mt-2 text-xs text-accent">
                        <Link href={href} onClick={(e) => e.stopPropagation()}>
                          Abrir detalhe
                        </Link>
                      </p>
                    ) : null}
                  </button>
                </li>
              )
            })}
          </ul>
        )}

        <button
          type="button"
          onClick={() => refetch()}
          className="mt-6 text-sm text-accent underline"
        >
          Atualizar lista
        </button>
      </div>
    </div>
  )
}
