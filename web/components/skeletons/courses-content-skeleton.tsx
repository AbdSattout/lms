import { Skeleton } from "@/components/ui/skeleton"

export function CoursesContentSkeleton() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between gap-4">
        <Skeleton className="h-9 w-24" />
        <Skeleton className="h-9 w-28" />
      </div>

      <div className="flex flex-col gap-4">
        <Skeleton className="h-7 w-18" />
        <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4 mask-fade-bottom *:aspect-video *:min-h-0 *:w-full">
          {Array.from({ length: 6 }).map((_, index) => (
            <Skeleton className="rounded-4xl" key={index} />
          ))}
        </div>
      </div>
    </div>
  )
}
