import { Skeleton } from "@/components/ui/skeleton"

export function MediaGridSkeleton() {
  return (
    <div className="@container">
      <div className="grid grid-cols-1 gap-4 mask-fade-bottom @sm:grid-cols-2 @lg:grid-cols-3 @xl:grid-cols-4">
        {Array.from({ length: 8 }).map((_, i) => (
          <div
            key={i}
            className="overflow-hidden rounded-3xl border border-border"
          >
            <Skeleton className="aspect-square w-full rounded-none" />
            <div className="p-3">
              <Skeleton className="mb-1 h-4 w-3/4" />
              <Skeleton className="h-3 w-1/2" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
