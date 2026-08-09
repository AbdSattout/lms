// app/[slug]/roadmaps/page.tsx
import { Suspense } from "react"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { RoadmapsContent } from "@/components/roadmap-content"
import { RoadmapsContentSkeleton } from "@/components/skeletons/roadmap-skeleton"

async function RoadmapsSection({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const roadmaps = await api.dashboard.roadmap
    .list(slug, { page: 0, size: 50 })
    .catch(() => ({ content: [] }))
  console.log("Fetched roadmaps:", roadmaps) // Debugging line
  return <RoadmapsContent orgSlug={slug} roadmaps={roadmaps.content ?? []} />
}

export default function RoadmapsPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  return (
    <>
      <BreadcrumbTrail items={[{ label: "المسارات التعليمية" }]} />
      <Suspense fallback={<RoadmapsContentSkeleton />}>
        <RoadmapsSection params={params} />
      </Suspense>
    </>
  )
}
