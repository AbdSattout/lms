// app/[slug]/posts/create/page.tsx
import { Suspense } from "react"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Skeleton } from "@/components/ui/skeleton"
import { CreatePostForm } from "@/components/forms/create-post-form"
import { api } from "@/lib/api"

export default async function CreatePostPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params

  const courses = await api.dashboard.organizations.courses
    .get(slug)
    .catch(() => [])

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "المنشورات", href: `/${slug}/posts` },
          { label: "إنشاء منشور" },
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
        <CreatePostForm orgSlug={slug} courses={courses} />
      </Suspense>
    </>
  )
}
