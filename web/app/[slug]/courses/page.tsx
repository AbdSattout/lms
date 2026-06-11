import { CoursesContent } from "@/components/courses-content"
import { api } from "@/lib/api"

export default async function CoursesPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const courses = await api.dashboard.organizations
    .courses(slug)
    .catch(() => null)

  return <CoursesContent orgSlug={slug} courses={courses ?? []} />
}
