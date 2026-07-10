import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  QuestionResponse,
  QuizResponse,
} from "@/lib/api/types"

export const byId = defineApiRoute({
  get: (quizId: number, options?: BackendFetchOptions) =>
    backend<QuizResponse>(`/quizzes/${quizId}`, {
      method: "GET",
      ...options,
    }),
})

export const addQuestion = defineApiRoute({
  post: (
    quizId: number,
    questionId: number,
    options?: BackendFetchOptions
  ) =>
    backend<QuestionResponse>(`/${quizId}/questions/${questionId}`, {
      method: "POST",
      ...options,
    }),
})

export const deleteQuestion = defineApiRoute({
  delete: (
    quizId: number,
    questionId: number,
    options?: BackendFetchOptions
  ) =>
    backend<void>(`/quizzes/${quizId}/questions/${questionId}`, {
      method: "DELETE",
      ...options,
    }),
})
