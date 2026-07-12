import { Skeleton } from "../ui/skeleton"

export function OrgsGridSkeleton() {
  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4 mask-fade-bottom *:aspect-video *:min-h-0 *:w-full">
      {Array.from({ length: 8 }).map((_, index) => (
        <Skeleton key={index} className="h-full rounded-4xl" />
      ))}
    </div>
  )
}
