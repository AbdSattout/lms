import { Card, CardContent } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

export function ChatSkeleton() {
  return (
    <Card className="absolute inset-0 flex h-[calc(100dvh-var(--spacing)*20)] flex-col gap-0 overflow-hidden py-0 md:h-[calc(100dvh-var(--spacing)*28)]">
      <CardContent className="flex min-h-0 flex-1 flex-col gap-4 px-4 py-4">
        <div className="flex items-end gap-2">
          <Skeleton className="h-10 w-2/3" />
        </div>
        <div className="flex flex-row-reverse items-end gap-2">
          <Skeleton className="size-7 shrink-0 rounded-full" />
          <Skeleton className="h-10 w-1/2" />
        </div>
        <div className="flex items-end gap-2">
          <Skeleton className="h-10 w-1/3" />
        </div>
        <div className="flex flex-row-reverse items-end gap-2">
          <Skeleton className="size-7 shrink-0 rounded-full" />
          <Skeleton className="h-10 w-2/3" />
        </div>
      </CardContent>
    </Card>
  )
}
