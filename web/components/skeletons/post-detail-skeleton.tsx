// components/skeletons/post-detail-skeleton.tsx
import { Skeleton } from "@/components/ui/skeleton"

export function PostDetailSkeleton() {
  return (
    <div className="flex max-w-3xl flex-col gap-6">
      {/* Post skeleton */}
      <div className="rounded-xl border bg-card p-6">
        <div className="mb-4 flex items-center gap-3">
          <Skeleton className="h-10 w-10 rounded-full" />
          <div>
            <Skeleton className="h-4 w-32" />
            <Skeleton className="mt-1 h-3 w-20" />
          </div>
        </div>
        <Skeleton className="mb-3 h-7 w-3/4" />
        <Skeleton className="mb-1 h-4 w-full" />
        <Skeleton className="mb-1 h-4 w-5/6" />
        <Skeleton className="mb-1 h-4 w-2/3" />
        <Skeleton className="mb-3 h-48 w-full rounded-lg" />
        <div className="mt-4 flex items-center gap-4 border-t pt-4">
          <Skeleton className="h-4 w-16" />
          <Skeleton className="h-4 w-16" />
        </div>
      </div>

      {/* Comment input skeleton */}
      <div className="rounded-xl border bg-card p-4">
        <Skeleton className="h-20 w-full rounded-lg" />
        <Skeleton className="mt-2 ml-auto h-8 w-20" />
      </div>

      {/* Comments skeleton */}
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i} className="flex gap-3 py-3">
          <Skeleton className="h-8 w-8 shrink-0 rounded-full" />
          <div className="flex-1">
            <Skeleton className="mb-1 h-4 w-24" />
            <Skeleton className="mb-1 h-4 w-full" />
            <Skeleton className="h-4 w-3/4" />
          </div>
        </div>
      ))}
    </div>
  )
}
