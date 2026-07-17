import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CreatePracticeExamRequest,
  PracticeExamResponse,
  UpdatePracticeExamQuestionsRequest,
} from "@/lib/api/types"

export const create = defineApiRoute({
  post: (
    courseId: number,
    request: CreatePracticeExamRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PracticeExamResponse>(`/dashboard/courses/${courseId}/practice-exams`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const list = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<PracticeExamResponse[]>(`/dashboard/courses/${courseId}/practice-exams`, {
      method: "GET",
      ...options,
    }),
})

export const byId = defineApiRoute({
  get: (courseId: number, practiceExamId: number, options?: BackendFetchOptions) =>
    backend<PracticeExamResponse>(
      `/dashboard/courses/${courseId}/practice-exams/${practiceExamId}`,
      {
        method: "GET",
        ...options,
      }
    ),
})

export const updateQuestions = defineApiRoute({
  patch: (
    courseId: number,
    practiceExamId: number,
    request: UpdatePracticeExamQuestionsRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PracticeExamResponse>(
      `/dashboard/courses/${courseId}/practice-exams/${practiceExamId}/questions`,
      {
        method: "PATCH",
        body: request,
        ...options,
      }
    ),
})

export const deleteExam = defineApiRoute({
  delete: (courseId: number, practiceExamId: number, options?: BackendFetchOptions) =>
    backend<void>(
      `/dashboard/courses/${courseId}/practice-exams/${practiceExamId}`,
      {
        method: "DELETE",
        ...options,
      }
    ),
})
