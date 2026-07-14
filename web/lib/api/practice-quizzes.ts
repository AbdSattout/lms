import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CreatePracticeQuizRequest,
  PracticeQuizResponse,
  PracticeQuizSummaryResponse,
  UpdatePracticeQuizQuestionsRequest,
} from "@/lib/api/types"

export const create = defineApiRoute({
  post: (
    courseId: number,
    request: CreatePracticeQuizRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PracticeQuizResponse>(`/dashboard/courses/${courseId}/practice-quizzes`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const list = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<PracticeQuizSummaryResponse[]>(`/dashboard/courses/${courseId}/practice-quizzes`, {
      method: "GET",
      ...options,
    }),
})

export const updateQuestions = defineApiRoute({
  patch: (
    courseId: number,
    practiceQuizId: number,
    request: UpdatePracticeQuizQuestionsRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PracticeQuizResponse>(
      `/dashboard/courses/${courseId}/practice-quizzes/${practiceQuizId}/questions`,
      {
        method: "PATCH",
        body: request,
        ...options,
      }
    ),
})
