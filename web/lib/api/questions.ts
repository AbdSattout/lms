import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { QuestionResponse } from "@/lib/api/types"
import type { CreateQuestionInput, UpdateQuestionInput } from "@/lib/validation"

export const create = defineApiRoute({
  post: (
    courseId: number,
    request: CreateQuestionInput,
    options?: BackendFetchOptions
  ) =>
    backend<QuestionResponse>(`/dashboard/courses/${courseId}/questions`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const byCourse = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<QuestionResponse[]>(`/dashboard/courses/${courseId}/questions`, {
      method: "GET",
      ...options,
    }),
})

export const byId = defineApiRoute({
  patch: (
    questionId: number,
    request: UpdateQuestionInput,
    options?: BackendFetchOptions
  ) =>
    backend<QuestionResponse>(`/dashboard/questions/${questionId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (questionId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/questions/${questionId}`, {
      method: "DELETE",
      ...options,
    }),
})
