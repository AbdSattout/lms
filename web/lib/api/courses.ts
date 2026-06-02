import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  ChapterResponse,
  CourseResponse,
  CreateChapterRequest,
  ReorderChaptersRequest,
  UpdateCourseRequest,
} from "@/lib/api/types"

function toFormData(fields: Record<string, unknown>) {
  const formData = new FormData()

  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined) continue

    if (value instanceof File) {
      formData.set(key, value)
      continue
    }

    formData.set(
      key,
      typeof value === "string" ? value : new Blob([JSON.stringify(value)], { type: "application/json" })
    )
  }

  return formData
}

export const byId = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<CourseResponse>(`/courses/${courseId}`, {
      method: "GET",
      ...options,
    }),
  delete: (courseId: number, options?: BackendFetchOptions) =>
    backend<void>(`/courses/${courseId}`, {
      method: "DELETE",
      ...options,
    }),
  patch: (
    courseId: number,
    request: UpdateCourseRequest,
    cover?: File,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(`/courses/${courseId}`, {
      method: "PATCH",
      body: toFormData({ request, cover }),
      ...options,
    }),
})

export const publish = defineApiRoute({
  post: (courseId: number, options?: BackendFetchOptions) =>
    backend<void>(`/courses/${courseId}/publish`, {
      method: "POST",
      ...options,
    }),
})

export const enroll = defineApiRoute({
  post: (courseId: number, options?: BackendFetchOptions) =>
    backend<CourseResponse>(`/courses/${courseId}/enroll`, {
      method: "POST",
      ...options,
    }),
  delete: (courseId: number, options?: BackendFetchOptions) =>
    backend<void>(`/courses/${courseId}/enroll`, {
      method: "DELETE",
      ...options,
    }),
})

export const chapters = {
  create: defineApiRoute({
    post: (
      courseId: number,
      request: CreateChapterRequest,
      options?: BackendFetchOptions
    ) =>
      backend<ChapterResponse>(`/courses/${courseId}/chapters`, {
        method: "POST",
        body: request,
        ...options,
      }),
  }),
  reorder: defineApiRoute({
    patch: (
      courseId: number,
      request: ReorderChaptersRequest,
      options?: BackendFetchOptions
    ) =>
      backend<void>(`/courses/${courseId}/chapters/reorder`, {
        method: "PATCH",
        body: request,
        ...options,
      }),
  }),
}
