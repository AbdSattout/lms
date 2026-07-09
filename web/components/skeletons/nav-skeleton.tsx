import { Skeleton } from "@/components/ui/skeleton"

export function NavSkeleton() {
  return (
    <div className="flex flex-col gap-0.5 px-2">
      {Array.from({ length: 4 }).map((_, i) => (
        <div key={i} className="flex items-center gap-2 rounded-md px-3 py-2">
          <Skeleton className="size-4" />
          <Skeleton className="h-4 w-20" />
        </div>
      ))}
    </div>
  )
}
