import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CreateLessonRequest,
  LessonResponse,
  ReorderLessonsRequest,
  UpdateLessonRequest,
} from "@/lib/api/types"

export const create = defineApiRoute({
  post: (
    chapterId: number,
    request: CreateLessonRequest,
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
    request: ReorderLessonsRequest,
    options?: BackendFetchOptions
  ) =>
    backend<void>(`/chapters/${chapterId}/lessons/reorder`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})

export const byId = defineApiRoute({
  patch: (
    lessonId: number,
    request: UpdateLessonRequest,
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
