import { Skeleton } from "@/components/ui/skeleton"

export function SidebarAccountDropdownSkeleton() {
  return (
    <div className="flex items-center gap-2 rounded-md px-3 py-2">
      <Skeleton className="size-8 rounded-lg" />
      <div className="grid flex-1 gap-2">
        <Skeleton className="h-4 w-24" />
        <Skeleton className="h-3 w-16" />
      </div>
    </div>
  )
}
