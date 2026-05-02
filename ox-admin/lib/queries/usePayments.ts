import { useQuery } from '@tanstack/react-query'
import api from '../api'

export interface Payment {
  id: string
  amount: number
  recipientType: string
  recipientId: string
  paidAt?: string
  stripeTransferId?: string
  escrow: {
    id: string
    status: string
    amount: number
    contract: {
      id: string
      totalAmount: number
      project: { id: string; title: string }
      worker: { id: string; user: { name: string } }
    }
  }
}

export interface PaymentStats {
  totalThisMonth: number
  released: number
  inEscrow: number
  weeklyData: { week: string; released: number; escrow: number }[]
}

export function usePayments() {
  return useQuery({
    queryKey: ['payments'],
    queryFn: async () => {
      const { data } = await api.get('/payments')
      return (Array.isArray(data) ? data : data?.data ?? data?.items ?? []) as Payment[]
    },
  })
}

export function usePaymentStats() {
  return useQuery({
    queryKey: ['payment-stats'],
    queryFn: async () => {
      const { data } = await api.get('/payments/stats')
      return data as PaymentStats
    },
  })
}
