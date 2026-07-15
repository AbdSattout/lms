"use server"

import { api } from "@/lib/api"
import type { QuizResponse } from "@/lib/api/types"
import { revalidatePath } from "next/cache"

export async function updateFinalQuizQuestionsAction(
  courseId: number,
  data: { questionIds: number[] },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; quiz?: QuizResponse }> {
  const quiz = await api.dashboard.quizzes.updateFinalQuizQuestions
    .patch(courseId, data)
    .catch(() => null)

  if (!quiz) return { error: "حدث خطأ أثناء تحديث أسئلة الاختبار النهائي" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}`)
  return { quiz }
}
