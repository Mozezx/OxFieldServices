'use client'
import { useRouter } from 'next/navigation'
import { Table, Thead, Tbody, Th, Td, Tr } from '@/components/ui/Table'
import { TableSkeleton } from '@/components/ui/Skeleton'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import { formatDate } from '@/lib/utils/formatDate'
import type { Project } from '@/lib/queries/useProjects'

interface ProjectsTableProps {
  projects?: Project[]
  isLoading?: boolean
}

export function ProjectsTable({ projects, isLoading }: ProjectsTableProps) {
  const router = useRouter()

  return (
    <Table>
      <Thead>
        <tr>
          <Th>#</Th>
          <Th>Título</Th>
          <Th>Cliente</Th>
          <Th>Status</Th>
          <Th>Valor</Th>
          <Th>Data</Th>
          <Th>Ações</Th>
        </tr>
      </Thead>
      <Tbody>
        {isLoading ? (
          <TableSkeleton rows={5} cols={7} />
        ) : projects?.length === 0 ? (
          <tr>
            <td colSpan={7} className="text-center py-12 text-text-secondary">
              Nenhum projeto encontrado.
            </td>
          </tr>
        ) : (
          projects?.map((project, index) => (
            <Tr key={project.id} onClick={() => router.push(`/projects/${project.id}`)}>
              <Td className="text-text-secondary">{index + 1}</Td>
              <Td className="font-medium">{project.title}</Td>
              <Td className="text-text-secondary">{project.client?.name ?? '—'}</Td>
              <Td><Badge status={project.status} /></Td>
              <Td>{formatCurrency(Number(project.budget))}</Td>
              <Td className="text-text-secondary">{formatDate(project.createdAt)}</Td>
              <Td>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={(e) => { e.stopPropagation(); router.push(`/projects/${project.id}`) }}
                >
                  Ver
                </Button>
              </Td>
            </Tr>
          ))
        )}
      </Tbody>
    </Table>
  )
}
