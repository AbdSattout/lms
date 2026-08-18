import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
import { ExamDetailClient } from "./exam-detail-client"

export default async function ExamDetailPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string; examId: string }>
}) {
  const { slug, courseSlug, examId } = await params

  const course = await api.dashboard.organizations
    .getCourseBySlug(slug, courseSlug)
    .catch(() => null)

  if (!course) notFound()

  const exam = await api.dashboard.practiceExams.byId
    .get(course.id, Number(examId))
    .catch(() => null)

  if (!exam) notFound()

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
            label: "الاختبارات والامتحانات",
            href: `/${slug}/courses/${courseSlug}/quizzes`,
          },
          { label: exam.title },
        ]}
      />
      <ExamDetailClient
        course={course}
        orgSlug={slug}
        exam={exam}
        bankQuestions={bankQuestions}
      />
    </>
  )
}
