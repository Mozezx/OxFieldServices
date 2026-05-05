import { useQuery } from '@tanstack/react-query'
import api from '../api'

export type AppRole = 'admin' | 'client' | 'worker'

export interface AuthMeUser {
  id?: string
  authId?: string
  email?: string
  name?: string
  role?: AppRole
  /** Presente quando o Supabase tem sessão mas ainda não existe linha em public."User". */
  _unsynced?: boolean
}

export function useAuthMe() {
  return useQuery({
    queryKey: ['auth', 'me'],
    queryFn: async () => {
      const { data } = await api.get<AuthMeUser>('/auth/me')
      return data
    },
  })
}
