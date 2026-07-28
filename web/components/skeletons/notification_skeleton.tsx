// components/skeletons/notification-skeleton.tsx
import { Skeleton } from "@/components/ui/skeleton"

export function NotificationSkeleton() {
  return (
    <div className="absolute top-full left-0 z-50 mt-2 w-80">
      <div className="space-y-3 rounded-lg border bg-card p-4">
        <Skeleton className="h-6 w-32" />
        {[1, 2, 3].map((i) => (
          <div key={i} className="space-y-2">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-3 w-3/4" />
            <Skeleton className="h-3 w-1/2" />
            <div className="mt-2 flex gap-2">
              <Skeleton className="h-8 flex-1" />
              <Skeleton className="h-8 flex-1" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
