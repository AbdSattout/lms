import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  ChapterResponse,
  EnrollmentResponse,
  CourseResponse,
} from "@/lib/api/types"
import type {
  CreateChapterInput,
  ReorderChaptersInput,
  UpdateCourseInput,
} from "@/lib/validation"

export const byId = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<CourseResponse>(`/dashboard/courses/${courseId}`, {
      method: "GET",
      ...options,
    }),
  delete: (courseId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/courses/${courseId}`, {
      method: "DELETE",
      ...options,
    }),
  patch: async (
    courseId: number,
    request: UpdateCourseInput,
    cover?: File,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(`/dashboard/courses/${courseId}`, {
      method: "PATCH",
      body: (() => {
        const body = new FormData()

        body.set("request", new Blob([JSON.stringify(request)], { type: "application/json" }))
        if (cover) body.set("cover", cover)

        return body
      })(),
      ...options,
    }),
})

export const publish = defineApiRoute({
  post: (courseId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/courses/${courseId}/publish`, {
      method: "POST",
      ...options,
    }),
})

export const enroll = defineApiRoute({
  post: (courseId: number, options?: BackendFetchOptions) =>
    backend<EnrollmentResponse>(`/courses/${courseId}/enroll`, {
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
      request: CreateChapterInput,
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
      request: ReorderChaptersInput,
      options?: BackendFetchOptions
    ) =>
      backend<void>(`/courses/${courseId}/chapters/reorder`, {
        method: "PATCH",
        body: request,
        ...options,
      }),
  }),
}
