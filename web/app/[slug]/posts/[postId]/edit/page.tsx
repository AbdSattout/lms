// app/[slug]/posts/edit/[postId]/page.tsx
import { Suspense } from "react"
import { notFound } from "next/navigation"
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Skeleton } from "@/components/ui/skeleton"
import { EditPostForm } from "@/components/forms/edit-post-form"
import { api } from "@/lib/api"

async function EditPostSection({
  slug,
  postId,
}: {
  slug: string
  postId: number
}) {
  const [post, courses] = await Promise.all([
    api.dashboard.posts.byId.get(postId).catch(() => null),
    api.dashboard.organizations.courses.get(slug).catch(() => []),
  ])

  if (!post) {
    notFound()
  }

  return <EditPostForm orgSlug={slug} post={post} courses={courses} />
}

export default async function EditPostPage({
  params,
}: {
  params: Promise<{ slug: string; postId: string }>
}) {
  const { slug, postId } = await params

  if (isNaN(Number(postId))) {
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
          <div className="flex flex-col gap-4">
            <Skeleton className="h-10 w-48" />
            <Skeleton className="h-12 w-full rounded-lg" />
            <Skeleton className="h-64 w-full rounded-lg" />
          </div>
        }
      >
        <EditPostSection slug={slug} postId={Number(postId)} />
      </Suspense>
    </>
  )
}
