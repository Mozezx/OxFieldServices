import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../api'

export interface CreateProjectPayload {
  title: string
  budget: number
  location: string
  deadline?: string
  clientId?: string
  clientEmail?: string
  submit?: boolean
  phases?: { name: string; order: number; amount: number }[]
}

export interface Project {
  id: string
  title: string
  status: string
  budget: number
  location: string
  deadline?: string
  createdAt: string
  client: { id: string; name: string; email: string }
  phases?: Phase[]
  contract?: Contract
}

export interface Phase {
  id: string
  name: string
  status: string
  order: number
  amount: number
  evidences?: Evidence[]
}

export interface Evidence {
  id: string
  type: string
  url: string
  uploadedAt: string
}

export interface Contract {
  id: string
  workerId: string
  totalAmount: number
  signedAt?: string | null
  worker?: { id: string; user: { name: string } }
  escrow?: { id: string } | null
}

export function useProjects(status?: string) {
  return useQuery({
    queryKey: ['projects', status],
    queryFn: async () => {
      const params: Record<string, string | number> = { take: 100 }
      if (status) params.status = status
      const { data } = await api.get('/projects', { params })
      return (Array.isArray(data) ? data : data?.data ?? data?.items ?? []) as Project[]
    },
  })
}

export function useProject(id: string) {
  return useQuery({
    queryKey: ['projects', id],
    queryFn: async () => {
      const { data } = await api.get(`/projects/${id}`)
      return data as Project
    },
    enabled: !!id,
  })
}

export function useCreateProject() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (payload: CreateProjectPayload) => {
      const { data } = await api.post<Project>('/projects', payload)
      return data
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['projects'] })
    },
  })
}

export function useUpdateProjectStatus() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, event }: { id: string; event: string }) =>
      api.patch(`/projects/${id}/status`, { event }),
    onSuccess: (_data, { id }) => {
      qc.invalidateQueries({ queryKey: ['projects'] })
      qc.invalidateQueries({ queryKey: ['projects', id] })
    },
  })
}
