import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CourseMediaResponse,
  PageCourseMediaResponse,
} from "@/lib/api/types"
import type { PageableInput } from "@/lib/validation"

function toQueryString(pageable: PageableInput) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const byCourse = defineApiRoute({
  get: (courseId: number, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<PageCourseMediaResponse>(
      `/courses/${courseId}/media${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (courseId: number, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<CourseMediaResponse>(`/courses/${courseId}/media`, {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const byId = defineApiRoute({
  get: (mediaId: number, options?: BackendFetchOptions) =>
    backend<CourseMediaResponse>(`/media/${mediaId}`, {
      method: "GET",
      ...options,
    }),
  patch: (mediaId: number, file?: File, name?: string, options?: BackendFetchOptions) => {
    const body = new FormData()

    if (file) body.set("file", file)
    if (name) body.set("name", name)

    return backend<CourseMediaResponse>(`/media/${mediaId}`, {
      method: "PATCH",
      body,
      ...options,
    })
  },
  delete: (mediaId: number, options?: BackendFetchOptions) =>
    backend<void>(`/media/${mediaId}`, {
      method: "DELETE",
      ...options,
    }),
})
