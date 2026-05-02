'use client'
import { Header } from '@/components/layout/Header'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Skeleton } from '@/components/ui/Skeleton'
import { Table, Thead, Tbody, Th, Td, Tr } from '@/components/ui/Table'
import { TableSkeleton } from '@/components/ui/Skeleton'
import { PaymentsChart } from '@/components/features/payments/PaymentsChart'
import { usePayments, usePaymentStats } from '@/lib/queries/usePayments'
import { formatCurrency } from '@/lib/utils/formatCurrency'
import { formatDate } from '@/lib/utils/formatDate'
import { TrendingUp, Wallet, Lock } from 'lucide-react'

export default function PaymentsPage() {
  const { data: payments, isLoading } = usePayments()
  const { data: stats, isLoading: statsLoading } = usePaymentStats()

  const kpis = [
    { label: 'Total este mês', value: stats?.totalThisMonth ?? 0, icon: TrendingUp },
    { label: 'Liberado (workers)', value: stats?.released ?? 0, icon: Wallet },
    { label: 'Em Escrow', value: stats?.inEscrow ?? 0, icon: Lock },
  ]

  return (
    <>
      <Header title="Pagamentos" />
      <div className="p-6 space-y-6">
        <PageHeader title="Pagamentos" subtitle="Relatório financeiro" />

        {/* KPIs */}
        <div className="grid grid-cols-3 gap-4">
          {kpis.map(({ label, value, icon: Icon }) => (
            <Card key={label}>
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-text-secondary text-sm mb-1">{label}</p>
                  {statsLoading
                    ? <Skeleton className="h-8 w-32 mt-1" />
                    : <p className="text-white text-2xl font-bold">{formatCurrency(value)}</p>}
                </div>
                <div className="w-10 h-10 bg-accent/10 rounded-lg flex items-center justify-center">
                  <Icon className="w-5 h-5 text-accent" />
                </div>
              </div>
            </Card>
          ))}
        </div>

        {/* Gráfico */}
        <Card>
          <h3 className="text-white font-semibold mb-4">Pagamentos por semana (liberado ao worker)</h3>
          {!statsLoading && (stats?.weeklyData?.length ?? 0) === 0 ? (
            <p className="text-text-secondary text-sm py-8 text-center">Ainda não há histórico semanal de liberações.</p>
          ) : (
            <PaymentsChart data={stats?.weeklyData ?? []} />
          )}
        </Card>

        {/* Tabela de transações */}
        <Card padding={false}>
          <div className="p-4 border-b border-divider">
            <h3 className="text-white font-semibold">Transações</h3>
          </div>
          <Table>
            <Thead>
              <tr>
                <Th>Projeto</Th>
                <Th>Worker</Th>
                <Th>Valor</Th>
                <Th>Tipo</Th>
                <Th>Status</Th>
                <Th>Data</Th>
              </tr>
            </Thead>
            <Tbody>
              {isLoading ? (
                <TableSkeleton rows={5} cols={6} />
              ) : payments?.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-text-secondary">
                    Nenhuma transação encontrada.
                  </td>
                </tr>
              ) : (
                payments?.map((payment) => (
                  <Tr key={payment.id}>
                    <Td>{payment.escrow?.contract?.project?.title ?? '—'}</Td>
                    <Td className="text-text-secondary">{payment.escrow?.contract?.worker?.user?.name ?? '—'}</Td>
                    <Td className="font-medium text-accent">{formatCurrency(Number(payment.amount))}</Td>
                    <Td className="text-text-secondary capitalize">{payment.recipientType}</Td>
                    <Td><Badge status={payment.escrow?.status ?? 'held'} /></Td>
                    <Td className="text-text-secondary">{payment.paidAt ? formatDate(payment.paidAt) : '—'}</Td>
                  </Tr>
                ))
              )}
            </Tbody>
          </Table>
        </Card>
      </div>
    </>
  )
}
