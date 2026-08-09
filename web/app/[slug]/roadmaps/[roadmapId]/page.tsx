import { Suspense } from "react"
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { RoadmapEditor } from "@/components/roadmap/roadmap-editor"
import { RoadmapEditorSkeleton } from "@/components/skeletons/roadmap-editor-skeleton"
import type { CourseResponse } from "@/lib/api/types"

async function RoadmapEditorSection({
  params,
}: {
  params: Promise<{ slug: string; roadmapId: string }>
}) {
  const { slug, roadmapId } = await params
  const isNew = roadmapId === "new"

  const coursesData = await api.dashboard.organizations
    .courses(slug)
    .catch(() => [] as CourseResponse[])

  const availableCourses: CourseResponse[] = Array.isArray(coursesData)
    ? coursesData
    : ((coursesData as { content?: CourseResponse[] })?.content ?? [])

  if (!isNew) {
    const id = parseInt(roadmapId, 10)
    if (isNaN(id)) notFound()

    const roadmap = await api.dashboard.roadmap.byId(slug, id).catch(() => null)

    if (!roadmap) notFound()

    return (
      <RoadmapEditor
        orgSlug={slug}
        roadmap={roadmap}
        isNew={false}
        availableCourses={availableCourses}
      />
    )
  }

  return (
    <RoadmapEditor
      orgSlug={slug}
      roadmap={null}
      isNew={true}
      availableCourses={availableCourses}
    />
  )
}

export default function RoadmapEditorPage({
  params,
}: {
  params: Promise<{ slug: string; roadmapId: string }>
}) {
  return (
    <div className="flex h-[calc(100vh-8rem)] flex-col space-y-4">
      <BreadcrumbTrail
        items={[
          { label: "المسارات التعليمية", href: ".." },
          { label: "تعديل المسار" },
        ]}
      />
      <Suspense fallback={<RoadmapEditorSkeleton />}>
        <RoadmapEditorSection params={params} />
      </Suspense>
    </div>
  )
}
