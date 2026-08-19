import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { CourseChat } from "@/components/course-chat/course-chat"
import { ChatSkeleton } from "@/components/course-chat/chat-skeleton"
import { api } from "@/lib/api"
import type { Role } from "@/lib/api/types"
import { notFound } from "next/navigation"
import { Suspense } from "react"

async function ChatSection({
  slug,
  courseSlug,
}: {
  slug: string
  courseSlug: string
}) {
  const [course, org, user] = await Promise.all([
    api.dashboard.organizations.getCourseBySlug(slug, courseSlug).catch(() => null),
    api.dashboard.organizations.bySlug(slug).catch(() => null),
    api.users.me().catch(() => null),
  ])

  if (!course || !user) notFound()

  const viewerRole: Role | undefined = org?.viewer?.role
  const canMute = viewerRole === "OWNER" || viewerRole === "ADMIN"

  return (
    <CourseChat
      course={course}
      currentUser={user}
      canMute={canMute}
      canDelete={canMute}
    />
  )
}

export default async function CourseChatPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params

  return (
    <div className="relative">
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: "دردشة الدورة" },
        ]}
      />
      <Suspense fallback={<ChatSkeleton />}>
        <ChatSection slug={slug} courseSlug={courseSlug} />
      </Suspense>
    </div>
  )
}
