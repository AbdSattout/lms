import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { QuestionsPageClient } from "./questions-client"

export default async function QuestionsPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const questions = await api.dashboard.questions.byCourse
    .get(course.id)
    .catch(() => [])

  return (
    <QuestionsPageClient
      courseId={course.id}
      orgSlug={slug}
      courseSlug={courseSlug}
      courseTitle={course.title}
      initialQuestions={questions}
    />
  )
}
