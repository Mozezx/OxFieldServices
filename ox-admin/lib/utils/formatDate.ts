import { format, parseISO } from 'date-fns'
import { ptBR } from 'date-fns/locale'

export function formatDate(date: string | Date, pattern = 'dd/MM/yyyy'): string {
  const d = typeof date === 'string' ? parseISO(date) : date
  return format(d, pattern, { locale: ptBR })
}
