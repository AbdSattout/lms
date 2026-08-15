import { Suspense } from "react"
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Skeleton } from "@/components/ui/skeleton"
import { CreatePostForm } from "@/components/forms/create-post-form"
import { api } from "@/lib/api"

export default async function CreateCoursePostPage({
  params,
}: {
  params: Promise<{ slug: string; courseId: string }>
}) {
  const { slug, courseId: idStr } = await params
  const courseId = parseInt(idStr, 10)

  const [courses, org] = await Promise.all([
    api.dashboard.organizations.courses.get(slug).catch(() => []),
    api.dashboard.organizations.bySlug.get(slug).catch(() => null),
  ])

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          {
            label: "منشورات الدورة",
            href: `/${slug}/courses/${courseId}/posts`,
          },
          { label: "إنشاء منشور مخصص" },
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
        <CreatePostForm
          orgSlug={slug}
          organizationId={org?.id}
          courses={courses}
          fixedCourseId={courseId}
        />
      </Suspense>
    </>
  )
}
