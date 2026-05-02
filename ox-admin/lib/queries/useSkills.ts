import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../api'

export interface Skill {
  id: string
  name: string
  label: string
}

export function useSkills() {
  return useQuery({
    queryKey: ['skills'],
    queryFn: async () => {
      const { data } = await api.get('/skills')
      return data as Skill[]
    },
  })
}

export function useCreateSkill() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (body: { name: string; label: string }) => api.post('/skills', body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['skills'] }),
  })
}

export function useDeleteSkill() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/skills/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['skills'] }),
  })
}
