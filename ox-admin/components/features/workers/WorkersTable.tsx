'use client'
import { useRouter } from 'next/navigation'
import { Table, Thead, Tbody, Th, Td, Tr } from '@/components/ui/Table'
import { TableSkeleton } from '@/components/ui/Skeleton'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { WorkerRatingStars } from './WorkerRatingStars'
import type { Worker } from '@/lib/queries/useWorkers'

interface WorkersTableProps {
  workers?: Worker[]
  isLoading?: boolean
}

export function WorkersTable({ workers, isLoading }: WorkersTableProps) {
  const router = useRouter()

  return (
    <Table>
      <Thead>
        <tr>
          <Th>Nome</Th>
          <Th>Skills</Th>
          <Th>Rating</Th>
          <Th>Status</Th>
          <Th>Ações</Th>
        </tr>
      </Thead>
      <Tbody>
        {isLoading ? (
          <TableSkeleton rows={5} cols={5} />
        ) : workers?.length === 0 ? (
          <tr>
            <td colSpan={5} className="text-center py-12 text-text-secondary">
              Nenhum worker encontrado.
            </td>
          </tr>
        ) : (
          workers?.map((worker) => (
            <Tr key={worker.id} onClick={() => router.push(`/workers/${worker.id}`)}>
              <Td>
                <div>
                  <p className="font-medium">{worker.user.name}</p>
                  <p className="text-xs text-text-secondary">{worker.user.email}</p>
                </div>
              </Td>
              <Td>
                <div className="flex flex-wrap gap-1">
                  {worker.skills.slice(0, 3).map((s) => (
                    <span key={s} className="text-xs bg-surface2 text-text-secondary px-2 py-0.5 rounded-full">{s}</span>
                  ))}
                  {worker.skills.length > 3 && (
                    <span className="text-xs text-text-disabled">+{worker.skills.length - 3}</span>
                  )}
                </div>
              </Td>
              <Td><WorkerRatingStars rating={Number(worker.rating)} size="sm" /></Td>
              <Td><Badge status={worker.available ? 'available' : 'occupied'} /></Td>
              <Td>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={(e) => { e.stopPropagation(); router.push(`/workers/${worker.id}`) }}
                >
                  Ver perfil
                </Button>
              </Td>
            </Tr>
          ))
        )}
      </Tbody>
    </Table>
  )
}
