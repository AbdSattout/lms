"use server"

import { api } from "@/lib/api"
import type { PracticeExamResponse } from "@/lib/api/types"
import {
  createPracticeExamSchema,
  updatePracticeExamQuestionsSchema,
} from "@/lib/validation"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"

export async function createPracticeExamAction(
  courseId: number,
  data: {
    title: string
    description?: string
    timeLimitMinutes?: number
    questionIds: number[]
  },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; exam?: PracticeExamResponse }> {
  const parsed = createPracticeExamSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const exam = await api.dashboard.practiceExams.create
    .post(courseId, parsed.data)
    .catch(() => null)

  if (!exam) return { error: "حدث خطأ أثناء إنشاء الامتحان" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes`)
  return { exam }
}

export async function updatePracticeExamQuestionsAction(
  courseId: number,
  examId: number,
  data: { questionIds: number[] },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; exam?: PracticeExamResponse }> {
  const parsed = updatePracticeExamQuestionsSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const exam = await api.dashboard.practiceExams.updateQuestions
    .patch(courseId, examId, parsed.data)
    .catch(() => null)

  if (!exam) return { error: "حدث خطأ أثناء تحديث أسئلة الامتحان" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes/exams/${examId}`)
  return { exam }
}

export async function publishPracticeExamAction(
  courseId: number,
  examId: number,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; exam?: PracticeExamResponse }> {
  const exam = await api.dashboard.practiceExams.publish
    .post(courseId, examId)
    .catch(() => null)

  if (!exam) return { error: "حدث خطأ أثناء نشر الامتحان" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes/exams/${examId}`)
  return { exam }
}

export async function deletePracticeExamAction(
  courseId: number,
  examId: number,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.practiceExams.delete
    .delete(courseId, examId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الامتحان" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes`)
  redirect(`/${orgSlug}/courses/${courseSlug}/quizzes`)
}
