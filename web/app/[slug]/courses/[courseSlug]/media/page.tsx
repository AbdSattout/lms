import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { CourseMediaClient } from "./media-client"

export default async function CourseMediaPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: course.title, href: `/${slug}/courses/${courseSlug}` },
          { label: "الوسائط" },
        ]}
      />
      <CourseMediaClient orgSlug={slug} course={course} />
    </>
  )
}
