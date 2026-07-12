import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { LessonDetailsResponse, LessonResponse } from "@/lib/api/types"
import type {
  CreateLessonInput,
  ReorderLessonsInput,
  UpdateLessonInput,
} from "@/lib/validation"

export const create = defineApiRoute({
  post: (
    chapterId: number,
    request: CreateLessonInput,
    options?: BackendFetchOptions
  ) =>
    backend<LessonResponse>(`/chapters/${chapterId}/lessons`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const reorder = defineApiRoute({
  patch: (
    chapterId: number,
    request: ReorderLessonsInput,
    options?: BackendFetchOptions
  ) =>
    backend<void>(`/chapters/${chapterId}/lessons/reorder`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})

export const byId = defineApiRoute({
  get: (lessonId: number, options?: BackendFetchOptions) =>
    backend<LessonDetailsResponse>(`/lessons/${lessonId}`, {
      method: "GET",
      ...options,
    }),
  patch: (
    lessonId: number,
    request: UpdateLessonInput,
    options?: BackendFetchOptions
  ) =>
    backend<LessonResponse>(`/lessons/${lessonId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (lessonId: number, options?: BackendFetchOptions) =>
    backend<void>(`/lessons/${lessonId}`, {
      method: "DELETE",
      ...options,
    }),
})
