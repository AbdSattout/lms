// components/skeletons/posts-list-skeleton.tsx
import { Skeleton } from "@/components/ui/skeleton"
import { PostCardSkeleton } from "@/components/skeletons/post-card-skeleton"
export function PostsListSkeleton() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <Skeleton className="h-9 w-24" />
        <Skeleton className="h-9 w-28" />
      </div>
      <div className="flex flex-col gap-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <PostCardSkeleton key={i} />
        ))}
      </div>
    </div>
  )
}
