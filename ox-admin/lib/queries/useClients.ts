import { useMutation } from '@tanstack/react-query'
import api from '../api'

export interface ClientLookup {
  id: string
  name: string
  email: string
  phone?: string | null
  role: string
  isNew: boolean
  unregistered?: boolean
}

export function useLookupOrCreateClient() {
  return useMutation({
    mutationFn: async (data: { email?: string; name?: string; phone?: string; unregistered?: boolean }) => {
      const { data: res } = await api.post<ClientLookup>('/admin/clients/lookup-or-create', data)
      return res
    },
  })
}
