import { Star } from 'lucide-react'
import { cn } from '@/lib/utils/cn'

interface WorkerRatingStarsProps {
  rating: number
  size?: 'sm' | 'md'
}

export function WorkerRatingStars({ rating, size = 'md' }: WorkerRatingStarsProps) {
  const stars = Array.from({ length: 5 }, (_, i) => i + 1)
  const iconSize = size === 'sm' ? 'w-3 h-3' : 'w-4 h-4'

  return (
    <div className="flex items-center gap-1">
      {stars.map((star) => (
        <Star
          key={star}
          className={cn(
            iconSize,
            star <= Math.round(rating) ? 'text-warning fill-warning' : 'text-text-disabled',
          )}
        />
      ))}
      <span className={cn('text-text-secondary ml-1', size === 'sm' ? 'text-xs' : 'text-sm')}>
        {rating.toFixed(1)}
      </span>
    </div>
  )
}
