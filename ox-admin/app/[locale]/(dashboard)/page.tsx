import { redirect } from 'next/navigation'

type Props = {
  params: { locale: string }
}

export default function DashboardPage({ params }: Props) {
  redirect(`/${params.locale}/projects`)
}
