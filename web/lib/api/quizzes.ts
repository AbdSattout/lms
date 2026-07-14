import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  QuizResponse,
  UpdateFinalQuizQuestionsRequest,
} from "@/lib/api/types"

export const getFinalQuiz = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<QuizResponse>(`/dashboard/courses/${courseId}/final-quiz`, {
      method: "GET",
      ...options,
    }),
})

export const updateFinalQuizQuestions = defineApiRoute({
  patch: (
    courseId: number,
    request: UpdateFinalQuizQuestionsRequest,
    options?: BackendFetchOptions
  ) =>
    backend<QuizResponse>(`/dashboard/courses/${courseId}/final-quiz/questions`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})
