import { Suspense } from "react"
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { PostsListSkeleton } from "@/components/skeletons/post-list-skeleton"
import { PostsContent } from "@/components/posts/post-content"

async function PostsSection({ slug }: { slug: string }) {
  const posts = await api.dashboard.posts
    .byOrg(slug, { page: 0, size: 20, sort: ["createdAt,desc"] })
    .catch((error) => {
      console.error("Failed to fetch posts in Server Component:", error)
      return null
    })

  return (
    <PostsContent
      orgSlug={slug}
      initialPosts={posts?.content ?? []}
      initialHasMore={
        (posts?.content?.length ?? 0) < (posts?.totalElements ?? 0)
      }
    />
  )
}

export default async function PostsPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params

  return (
    <>
      <BreadcrumbTrail items={[{ label: "المنشورات" }]} />
      <Suspense fallback={<PostsListSkeleton />}>
        <PostsSection slug={slug} />
      </Suspense>
    </>
  )
}
