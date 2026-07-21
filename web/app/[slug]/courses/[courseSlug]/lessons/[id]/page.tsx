import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { LessonEditor } from "@/components/lesson-editor"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"

export default async function LessonPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string; id: string }>
}) {
  const { slug, courseSlug, id } = await params
  const lessonId = Number(id)
  if (isNaN(lessonId)) notFound()

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const [lesson, blocks, bankQuestions] = await Promise.all([
    api.dashboard.lessons.byId.get(lessonId).catch(() => null),
    api.dashboard.blocks.byLesson.get(lessonId).catch(() => []),
    api.dashboard.questions.byCourse.get(course.id).catch(() => []),
  ])

  if (!lesson) notFound()

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: course.title, href: `/${slug}/courses/${courseSlug}` },
          { label: lesson.title },
        ]}
      />
      <LessonEditor
        lesson={lesson}
        course={course}
        orgSlug={slug}
        initialBlocks={blocks}
        bankQuestions={bankQuestions}
      />
    </>
  )
}
