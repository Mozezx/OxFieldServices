import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../api'

export interface Worker {
  id: string
  skills: string[]
  rating: number
  shelterCertified: boolean
  available: boolean
  user: { id: string; name: string; email: string; phone?: string }
  _count?: { contracts: number }
}

export interface Candidate extends Worker {
  matchScore: number
  matchingSkills: string[]
  missingSkills: string[]
}

export function useWorkers() {
  return useQuery({
    queryKey: ['workers'],
    queryFn: async () => {
      const { data } = await api.get('/workers')
      return (Array.isArray(data) ? data : data?.data ?? data?.items ?? []) as Worker[]
    },
  })
}

export function useWorker(id: string) {
  return useQuery({
    queryKey: ['workers', id],
    queryFn: async () => {
      const { data } = await api.get(`/workers/${id}`)
      return data as Worker
    },
    enabled: !!id,
  })
}

export function useCandidates(projectId: string) {
  return useQuery({
    queryKey: ['candidates', projectId],
    queryFn: async () => {
      const { data } = await api.get(`/matching/${projectId}/candidates`)
      return data as Candidate[]
    },
    enabled: !!projectId,
  })
}

export function useAssignWorker() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ projectId, workerId }: { projectId: string; workerId: string }) =>
      api.post(`/matching/${projectId}/assign`, { workerId }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['projects'] })
      qc.invalidateQueries({ queryKey: ['candidates'] })
    },
  })
}

export interface UpdateWorkerInput {
  available?: boolean
  shelterCertified?: boolean
  skills?: string[]
}

export function useUpdateWorker(workerId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (input: UpdateWorkerInput) => {
      const { data } = await api.patch(`/workers/${workerId}`, input)
      return data as Worker
    },
    onSuccess: (data) => {
      qc.setQueryData(['workers', workerId], data)
      qc.invalidateQueries({ queryKey: ['workers'] })
      qc.invalidateQueries({ queryKey: ['candidates'] })
    },
  })
}
