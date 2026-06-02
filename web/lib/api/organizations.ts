import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CreateCourseRequest,
  CreateOrganizationRequest,
  CourseResponse,
  OrganizationResponse,
  Pageable,
  PageCourseResponse,
  UpdateOrganizationRequest,
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

function toQueryString(pageable?: Pageable) {
  if (!pageable) return ""

  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const list = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<OrganizationResponse[]>("/organizations", {
      method: "GET",
      ...options,
    }),
  post: (
    request: CreateOrganizationRequest,
    image?: File,
    options?: BackendFetchOptions
  ) =>
    backend<OrganizationResponse>("/organizations", {
      method: "POST",
      body: toFormData({ request, image }),
      ...options,
    }),
})

export const bySlug = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationResponse>(`/organizations/${slug}`, {
      method: "GET",
      ...options,
    }),
  patch: (
    slug: string,
    request: UpdateOrganizationRequest,
    image?: File,
    options?: BackendFetchOptions
  ) =>
    backend<OrganizationResponse>(`/organizations/${slug}`, {
      method: "PATCH",
      body: toFormData({ request, image }),
      ...options,
    }),
  delete: (slug: string, options?: BackendFetchOptions) =>
    backend<void>(`/organizations/${slug}`, {
      method: "DELETE",
      ...options,
    }),
})

export const courses = defineApiRoute({
  get: (
    slug: string,
    pageable?: Pageable,
    options?: BackendFetchOptions
  ) =>
    backend<PageCourseResponse>(
      `/organizations/${slug}/courses${toQueryString(pageable)}`,
      {
        method: "GET",
        ...options,
      }
    ),
  post: (
    slug: string,
    request: CreateCourseRequest,
    cover?: File,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(`/organizations/${slug}/courses`, {
      method: "POST",
      body: toFormData({ request, cover }),
      ...options,
    }),
})
