import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { QuizDetailClient } from "./quiz-detail-client"

export default async function QuizDetailPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string; quizId: string }>
}) {
  const { slug, courseSlug, quizId } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const quiz = await api.dashboard.practiceQuizzes.byId
    .get(course.id, Number(quizId))
    .catch(() => null)

  if (!quiz) notFound()

  const bankQuestions = await api.dashboard.questions.byCourse
    .get(course.id)
    .catch(() => [])

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: course.title, href: `/${slug}/courses/${courseSlug}` },
          {
            label: "الاختبارات",
            href: `/${slug}/courses/${courseSlug}/quizzes`,
          },
          { label: quiz.title },
        ]}
      />
      <QuizDetailClient
        courseId={course.id}
        orgSlug={slug}
        courseSlug={courseSlug}
        quiz={quiz}
        bankQuestions={bankQuestions}
      />
    </>
  )
}
