/** UI padrão em EUR; locale pt-BR mantém separadores habituais em PT. */
export function formatCurrency(value: number, currency = 'EUR'): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency }).format(value)
}
