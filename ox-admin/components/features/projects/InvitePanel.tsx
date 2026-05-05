'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import toast from 'react-hot-toast'
import { Link2, Copy, Trash2, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { useProjectInvites, useCreateInvite, useRevokeInvite, CreatedInvite } from '@/lib/queries/useInvites'
import { formatDate } from '@/lib/utils/formatDate'

interface Props {
  projectId: string
  clientPhone?: string | null
  compact?: boolean
}

export function InvitePanel({ projectId, clientPhone, compact = false }: Props) {
  const t = useTranslations('invitePanel')
  const [freshInvite, setFreshInvite] = useState<CreatedInvite | null>(null)

  const { data: invites, isLoading } = useProjectInvites(projectId)
  const createMut = useCreateInvite(projectId)
  const revokeMut = useRevokeInvite(projectId)

  async function handleCreate() {
    try {
      const inv = await createMut.mutateAsync(14)
      setFreshInvite(inv)
      copyToClipboard(inv.url)
    } catch {
      toast.error(t('errorCreate'))
    }
  }

  async function handleRevoke(inviteId: string) {
    try {
      await revokeMut.mutateAsync(inviteId)
      toast.success(t('revoked'))
    } catch {
      toast.error(t('errorRevoke'))
    }
  }

  function copyToClipboard(text: string) {
    navigator.clipboard.writeText(text)
    toast.success(t('copied'))
  }

  const statusColor: Record<string, string> = {
    active: 'text-green-400',
    used: 'text-text-disabled',
    expired: 'text-warning',
  }

  const visibleInvites = (invites ?? []).filter((inv) => inv.status !== 'revoked')

  if (compact) {
    return (
      <div className="flex items-center justify-end">
        <Button variant="primary" size="sm" onClick={handleCreate} disabled={createMut.isPending}>
          {createMut.isPending ? t('generating') : t('generateLink')}
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-white font-semibold flex items-center gap-2">
          <Link2 className="w-4 h-4 text-accent" />
          {t('title')}
        </h3>
        <Button variant="primary" size="sm" onClick={handleCreate} disabled={createMut.isPending}>
          {createMut.isPending ? t('generating') : t('generateLink')}
        </Button>
      </div>

      {/* Fresh invite — show once */}
      {freshInvite && (
        <div className="p-3 rounded-lg bg-accent/10 border border-accent/30 space-y-2">
          <p className="text-xs text-accent font-medium">{t('freshTitle')}</p>
          <div className="flex items-center gap-2">
            <code className="text-xs text-white flex-1 break-all">{freshInvite.url}</code>
            <button onClick={() => copyToClipboard(freshInvite.url)} className="text-accent hover:text-white flex-shrink-0">
              <Copy className="w-4 h-4" />
            </button>
          </div>
          <p className="text-xs text-text-secondary">{t('expiresAt', { date: formatDate(freshInvite.expiresAt) })}</p>
          {clientPhone && (
            <div className="flex gap-2 pt-1">
              <a
                href={`https://wa.me/${clientPhone.replace(/\D/g, '')}?text=${encodeURIComponent(freshInvite.url)}`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-accent hover:underline"
              >
                {t('sendWhatsapp')}
              </a>
            </div>
          )}
        </div>
      )}

      {/* Invite list */}
      {isLoading ? (
        <p className="text-text-secondary text-sm">{t('loading')}</p>
      ) : visibleInvites.length === 0 ? (
        <p className="text-text-disabled text-sm">{t('empty')}</p>
      ) : (
        <div className="space-y-2">
          {visibleInvites.map((inv) => (
            <div
              key={inv.id}
              className="flex items-center justify-between p-3 rounded-lg bg-surface border border-divider text-sm"
            >
              <div className="space-y-0.5">
                <p className={`font-medium ${statusColor[inv.status] ?? 'text-white'}`}>
                  {t(`status.${inv.status}`)}
                </p>
                <p className="text-text-disabled text-xs">
                  {t('createdAt', { date: formatDate(inv.createdAt) })}
                  {inv.usedAt && ` · ${t('usedAt', { date: formatDate(inv.usedAt) })}`}
                </p>
                <p className="text-text-disabled text-xs">
                  {t('expiresAt', { date: formatDate(inv.expiresAt) })}
                </p>
              </div>
              {inv.status === 'active' && (
                <button
                  onClick={() => handleRevoke(inv.id)}
                  disabled={revokeMut.isPending}
                  className="text-error hover:text-error/80 ml-2"
                  title={t('revoke')}
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          ))}
        </div>
      )}

      {(freshInvite || visibleInvites.length > 0) && (
        <button
          onClick={() => setFreshInvite(null)}
          className="flex items-center gap-1 text-xs text-text-secondary hover:text-white"
        >
          <RefreshCw className="w-3 h-3" /> {t('refresh')}
        </button>
      )}
    </div>
  )
}
