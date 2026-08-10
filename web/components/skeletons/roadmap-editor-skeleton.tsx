// components/skeletons/roadmap-editor-skeleton.tsx
import { Skeleton } from "@/components/ui/skeleton"

export function RoadmapEditorSkeleton() {
  return (
    <div className="flex h-[calc(100vh-8rem)] flex-col gap-4">
      {/* Toolbar Skeleton */}
      <div className="flex items-center justify-between rounded-lg border bg-card p-4">
        <Skeleton className="h-7 w-48" />
        <div className="flex items-center gap-2">
          <Skeleton className="h-9 w-28" />
          <Skeleton className="h-9 w-20" />
          <Skeleton className="h-9 w-20" />
          <Skeleton className="h-9 w-9" />
        </div>
      </div>

      {/* Flow Canvas Skeleton */}
      <div className="flex-1 rounded-lg border bg-card p-8">
        <div className="flex h-full flex-col items-center justify-center gap-6">
          {/* Simulated nodes */}
          <div className="relative flex flex-col items-center gap-12">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="flex flex-col items-center gap-12">
                <Skeleton className="h-28 w-56 rounded-lg" />
                {i < 2 && (
                  <div className="flex items-center justify-center">
                    <div className="h-12 w-0.5 bg-muted" />
                  </div>
                )}
              </div>
            ))}
          </div>
          <p className="text-sm text-muted-foreground">جاري تحميل المحرر...</p>
        </div>
      </div>
    </div>
  )
}
