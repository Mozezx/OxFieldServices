import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../api'

export interface ProjectInvite {
  id: string
  projectId: string
  clientId: string
  expiresAt: string
  usedAt?: string | null
  revokedAt?: string | null
  createdById: string
  createdAt: string
  status: 'active' | 'used' | 'expired' | 'revoked'
}

export interface CreatedInvite {
  id: string
  token: string
  url: string
  expiresAt: string
  projectId: string
}

export function useProjectInvites(projectId: string) {
  return useQuery({
    queryKey: ['invites', projectId],
    queryFn: async () => {
      const { data } = await api.get<ProjectInvite[]>(`/projects/${projectId}/invites`)
      return data
    },
    enabled: !!projectId,
  })
}

export function useCreateInvite(projectId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (expiresInDays?: number) => {
      const { data } = await api.post<CreatedInvite>(`/projects/${projectId}/invites`, {
        expiresInDays,
      })
      return data
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['invites', projectId] })
    },
  })
}

export function useRevokeInvite(projectId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (inviteId: string) => {
      await api.delete(`/invites/${inviteId}`)
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['invites', projectId] })
    },
  })
}
