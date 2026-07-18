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
  get: (organizationSlug: string, courseSlug: string, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<PageCourseMediaResponse>(
      `/dashboard/organizations/${organizationSlug}/courses/${courseSlug}/media${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (organizationSlug: string, courseSlug: string, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<CourseMediaResponse>(`/dashboard/organizations/${organizationSlug}/courses/${courseSlug}/media`, {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const byId = defineApiRoute({
  get: (organizationSlug: string, courseSlug: string, mediaId: number, options?: BackendFetchOptions) =>
    backend<CourseMediaResponse>(`/dashboard/organizations/${organizationSlug}/courses/${courseSlug}/media/${mediaId}`, {
      method: "GET",
      ...options,
    }),
  patch: (organizationSlug: string, courseSlug: string, mediaId: number, file?: File, name?: string, options?: BackendFetchOptions) => {
    const body = new FormData()

    if (file) body.set("file", file)
    if (name) body.set("name", name)

    return backend<CourseMediaResponse>(`/dashboard/organizations/${organizationSlug}/courses/${courseSlug}/media/${mediaId}`, {
      method: "PATCH",
      body,
      ...options,
    })
  },
  delete: (organizationSlug: string, courseSlug: string, mediaId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${organizationSlug}/courses/${courseSlug}/media/${mediaId}`, {
      method: "DELETE",
      ...options,
    }),
})
