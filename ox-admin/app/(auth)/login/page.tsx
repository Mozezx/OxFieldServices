'use client'
import { useState } from 'react'
import { Input } from '@/components/ui/Input'
import { Button } from '@/components/ui/Button'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import toast from 'react-hot-toast'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    const supabase = createClient()
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    setLoading(false)

    if (error) {
      toast.error(error.message)
      return
    }

    router.push('/projects')
    router.refresh()
  }

  return (
    <div className="min-h-screen bg-primary flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-surface border border-divider rounded-card p-10">
        <div className="text-center mb-8">
          <div className="text-accent text-4xl font-black mb-2">OX</div>
          <h1 className="text-white text-xl font-bold">Painel Administrativo</h1>
          <p className="text-text-secondary text-sm mt-1">Acesso restrito a administradores</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="E-mail"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="admin@ox.com"
            required
          />
          <Input
            label="Senha"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
          />
          <Button
            type="submit"
            variant="primary"
            isLoading={loading}
            className="w-full mt-2"
            size="lg"
          >
            Entrar no Painel
          </Button>
        </form>
      </div>
    </div>
  )
}
