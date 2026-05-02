'use client'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts'
import { formatCurrency } from '@/lib/utils/formatCurrency'

interface PaymentsChartProps {
  data: { week: string; released: number; escrow: number }[]
}

export function PaymentsChart({ data }: PaymentsChartProps) {
  return (
    <ResponsiveContainer width="100%" height={240}>
      <BarChart data={data} margin={{ top: 4, right: 4, left: 4, bottom: 4 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#1A5570" />
        <XAxis dataKey="week" tick={{ fill: '#A8C4CE', fontSize: 12 }} />
        <YAxis tick={{ fill: '#A8C4CE', fontSize: 12 }} tickFormatter={(v) => formatCurrency(Number(v)).replace(/\s/g, ' ')} />
        <Tooltip
          contentStyle={{ background: '#0D3F52', border: '1px solid #1A5570', borderRadius: 8 }}
          labelStyle={{ color: '#fff' }}
          formatter={(value: number) => formatCurrency(value)}
        />
        <Legend wrapperStyle={{ color: '#A8C4CE', fontSize: 12 }} />
        <Bar dataKey="released" name="Liberado" fill="#03FC30" radius={[4, 4, 0, 0]} />
        <Bar dataKey="escrow" name="Em Escrow" fill="#0D3F52" stroke="#1A5570" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  )
}
