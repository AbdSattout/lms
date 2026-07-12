import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { CourseManagement } from "@/components/course-management"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"

export default async function CoursePage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const chapters = await api.dashboard.courses.chapters.list
    .get(course.id)
    .catch(() => [])

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: course.title },
        ]}
      />
      <CourseManagement
        course={course}
        orgSlug={slug}
        initialChapters={chapters}
      />
    </>
  )
}
