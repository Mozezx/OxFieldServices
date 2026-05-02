'use client'

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import api from '@/lib/api'

export function useUnreadNotificationsCount() {
  return useQuery({
    queryKey: ['notifications', 'unread-count'],
    queryFn: async () => {
      const { data } = await api.get<{ count: number }>('/notifications/unread-count')
      return data.count
    },
    refetchInterval: 60_000,
  })
}

export type NotificationRow = {
  id: string
  type: string
  title: string
  body: string
  entityType: string | null
  entityId: string | null
  data?: Record<string, unknown> | null
  readAt: string | null
  createdAt: string
}

export function useNotificationsList() {
  return useQuery({
    queryKey: ['notifications', 'list'],
    queryFn: async () => {
      const { data } = await api.get<{
        items: NotificationRow[]
        nextCursor: string | null
      }>('/notifications', { params: { limit: 50 } })
      return data
    },
  })
}

export function useMarkNotificationRead() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      await api.patch(`/notifications/${id}/read`)
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['notifications'] })
    },
  })
}

export function useMarkAllNotificationsRead() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      await api.patch('/notifications/read-all')
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['notifications'] })
    },
  })
}
