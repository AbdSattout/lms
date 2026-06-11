import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CourseMediaResponse,
  PageCourseMediaResponse,
  Pageable,
} from "@/lib/api/types"

function toQueryString(pageable: Pageable) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const byCourse = defineApiRoute({
  get: (courseId: number, pageable: Pageable, options?: BackendFetchOptions) =>
    backend<PageCourseMediaResponse>(
      `/dashboard/courses/${courseId}/media${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (courseId: number, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<CourseMediaResponse>(`/dashboard/courses/${courseId}/media`, {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const byId = defineApiRoute({
  get: (mediaId: number, options?: BackendFetchOptions) =>
    backend<CourseMediaResponse>(`/dashboard/media/${mediaId}`, {
      method: "GET",
      ...options,
    }),
  patch: (mediaId: number, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<CourseMediaResponse>(`/dashboard/media/${mediaId}`, {
      method: "PATCH",
      body,
      ...options,
    })
  },
  delete: (mediaId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/media/${mediaId}`, {
      method: "DELETE",
      ...options,
    }),
})
