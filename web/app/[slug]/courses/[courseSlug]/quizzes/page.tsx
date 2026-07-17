import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { QuizzesClient } from "./quizzes-client"

export default async function QuizzesPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const [quizzes, bankQuestions] = await Promise.all([
    api.dashboard.practiceQuizzes.list(course.id).catch(() => []),
    api.dashboard.questions.byCourse.get(course.id).catch(() => []),
  ])

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: course.title, href: `/${slug}/courses/${courseSlug}` },
          { label: "الاختبارات" },
        ]}
      />
      <QuizzesClient
        course={course}
        orgSlug={slug}
        initialQuizzes={quizzes}
        initialBankQuestions={bankQuestions}
      />
    </>
  )
}
