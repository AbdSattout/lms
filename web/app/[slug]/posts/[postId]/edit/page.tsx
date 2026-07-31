import { Suspense } from "react"
import { notFound } from "next/navigation"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Skeleton } from "@/components/ui/skeleton"
import { EditPostForm } from "@/components/forms/edit-post-form"
import { getPostById } from "@/lib/actions/post"

async function EditPostData({
  slug,
  postId,
}: {
  slug: string
  postId: number
}) {
  const post = await getPostById(postId, slug)

  if (!post) {
    notFound()
  }
  return <EditPostForm orgSlug={slug} post={post} />
}

export default async function EditPostPage({
  params,
}: {
  params: Promise<{ slug: string; postId: string }>
}) {
  const { slug, postId: postIdString } = await params
  const postId = parseInt(postIdString, 10)

  if (isNaN(postId)) {
    notFound()
  }

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "المنشورات", href: `/${slug}/posts` },
          { label: "تعديل المنشور" },
        ]}
      />
      <Suspense
        fallback={
          <div className="mx-auto flex w-full max-w-4xl flex-col gap-4 pt-6">
            <Skeleton className="h-10 w-48" />
            <Skeleton className="h-12 w-full rounded-lg" />
            <Skeleton className="h-64 w-full rounded-lg" />
          </div>
        }
      >
        <EditPostData slug={slug} postId={postId} />
      </Suspense>
    </>
  )
}
