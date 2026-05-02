import { Sidebar } from '@/components/layout/Sidebar'
import { getUser } from '@/lib/auth'

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const user = await getUser()

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <main className="flex-1 overflow-y-auto bg-primary">
        {children}
      </main>
    </div>
  )
}
