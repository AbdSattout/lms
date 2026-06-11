import { CoursesContent } from "@/components/courses-content"
import { api } from "@/lib/api"

export default async function CoursesPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const page = await api.organizations
    .courses(slug, { page: 0, size: 50 })
    .catch(() => null)

  return <CoursesContent orgSlug={slug} courses={page?.content ?? []} />
}
