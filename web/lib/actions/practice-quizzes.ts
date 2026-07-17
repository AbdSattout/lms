"use server"

import { api } from "@/lib/api"
import type { PracticeQuizResponse } from "@/lib/api/types"
import {
  createPracticeQuizSchema,
  updatePracticeQuizQuestionsSchema,
} from "@/lib/validation"
import { revalidatePath } from "next/cache"

export async function createPracticeQuizAction(
  courseId: number,
  data: { title: string; description?: string; questionIds: number[] },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; quiz?: PracticeQuizResponse }> {
  const parsed = createPracticeQuizSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const quiz = await api.dashboard.practiceQuizzes.create
    .post(courseId, parsed.data)
    .catch(() => null)

  if (!quiz) return { error: "حدث خطأ أثناء إنشاء الاختبار" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes`)
  return { quiz }
}

export async function updatePracticeQuizQuestionsAction(
  courseId: number,
  quizId: number,
  data: { questionIds: number[] },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; quiz?: PracticeQuizResponse }> {
  const parsed = updatePracticeQuizQuestionsSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const quiz = await api.dashboard.practiceQuizzes.updateQuestions
    .patch(courseId, quizId, parsed.data)
    .catch(() => null)

  if (!quiz) return { error: "حدث خطأ أثناء تحديث أسئلة الاختبار" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes/${quizId}`)
  return { quiz }
}

export async function deletePracticeQuizAction(
  courseId: number,
  quizId: number,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.practiceQuizzes.delete
    .delete(courseId, quizId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الاختبار" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/quizzes`)
  return {}
}
