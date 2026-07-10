import { Suspense } from "react"

import { CoursesContent } from "@/components/courses-content"
import { CoursesContentSkeleton } from "@/components/skeletons/courses-content-skeleton"
import { api } from "@/lib/api"

async function CoursesSection({
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

export default function CoursesPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  return (
    <Suspense fallback={<CoursesContentSkeleton />}>
      <CoursesSection params={params} />
    </Suspense>
  )
}
