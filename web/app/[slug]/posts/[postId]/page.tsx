// app/[slug]/posts/[postId]/page.tsx
import { Suspense } from "react"
import { notFound } from "next/navigation" // أضف هذا الاستيراد

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { PostDetail } from "@/components/posts/post-detail"
import { PostDetailSkeleton } from "@/components/skeletons/post-detail-skeleton"
import { api } from "@/lib/api"

async function PostDetailSection({
  slug,
  postId,
}: {
  slug: string
  postId: number
}) {
  const [post, comments] = await Promise.all([
    api.dashboard.posts.byId.get(postId).catch(() => null),
    api.dashboard.posts.comments.get(postId).catch(() => []),
  ])

  if (!post) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <p className="text-lg text-muted-foreground">المنشور غير موجود</p>
      </div>
    )
  }

  return <PostDetail post={post} comments={comments ?? []} orgSlug={slug} />
}

export default async function PostDetailPage({
  params,
}: {
  params: Promise<{ slug: string; postId: string }>
}) {
  const { slug, postId } = await params

  // هذا الشرط يمنع الصفحة من التقاط مسار 'create' ويعالجه بشكل صحيح
  if (isNaN(Number(postId))) {
    notFound()
  }

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "المنشورات", href: `/${slug}/posts` },
          { label: "تفاصيل المنشور" },
        ]}
      />
      <Suspense fallback={<PostDetailSkeleton />}>
        <PostDetailSection slug={slug} postId={Number(postId)} />
      </Suspense>
    </>
  )
}
