// components/posts/post-card-skeleton.tsx
import { Skeleton } from "@/components/ui/skeleton"

export function PostCardSkeleton() {
  return (
    <div className="rounded-xl border bg-card p-4 md:p-6">
      {/* Header */}
      <div className="mb-3 flex items-center gap-3">
        <Skeleton className="h-8 w-8 rounded-full" />
        <div>
          <Skeleton className="h-4 w-24" />
          <Skeleton className="mt-1 h-3 w-16" />
        </div>
      </div>

      {/* Title */}
      <Skeleton className="mb-2 h-6 w-3/4" />

      {/* Image placeholder */}
      <Skeleton className="mb-3 h-48 w-full rounded-lg" />

      {/* Preview text */}
      <Skeleton className="mb-1 h-4 w-full" />
      <Skeleton className="mb-1 h-4 w-5/6" />
      <Skeleton className="mb-3 h-4 w-2/3" />

      {/* Footer */}
      <div className="flex items-center gap-4 border-t pt-2">
        <Skeleton className="h-4 w-12" />
        <Skeleton className="h-4 w-12" />
      </div>
    </div>
  )
}
