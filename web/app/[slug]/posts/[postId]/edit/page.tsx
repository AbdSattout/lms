import { Suspense } from "react"
import { notFound } from "next/navigation"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Skeleton } from "@/components/ui/skeleton"
import { EditPostForm } from "@/components/forms/edit-post-form"
import { getPostById } from "@/lib/actions/post"
import { api } from "@/lib/api"

async function EditPostData({
  slug,
  postId,
}: {
  slug: string
  postId: number
}) {
  const post = await getPostById(postId)

  if (!post) {
    notFound()
  }

  const courses = await api.dashboard.organizations.courses
    .get(slug)
    .catch(() => [])

  return <EditPostForm orgSlug={slug} post={post} courses={courses} />
}

export default async function EditPostPage({
  params,
}: {
  // ✅ Change `id` to `postId` in the params definition to match the folder [postId]
  params: Promise<{ slug: string; postId: string }>
}) {
  // ✅ Extract `postId` as a string and parse it to a number
  const { slug, postId: postIdString } = await params
  const postId = parseInt(postIdString, 10)

  // This check caused the 404 earlier because it was parsing 'undefined' (id). Now it correctly gets `postId`!
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
