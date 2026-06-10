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

function toQueryString(pageable: Pageable) {
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
  ) => {
    const body = new FormData()

    body.set("request", new Blob([JSON.stringify(request)], { type: "application/json" }))
    if (image) body.set("image", image)

    return backend<OrganizationResponse>("/dashboard/organizations", {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const bySlug = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationResponse>(`/dashboard/organizations/${slug}`, {
      method: "GET",
      ...options,
    }),
  patch: async (
    slug: string,
    request: UpdateOrganizationRequest,
    image?: File,
    options?: BackendFetchOptions
  ) =>
    backend<OrganizationResponse>(`/dashboard/organizations/${slug}`, {
      method: "PATCH",
      body: (() => {
        const body = new FormData()

        body.set("request", new Blob([JSON.stringify(request)], { type: "application/json" }))
        if (image) body.set("image", image)

        return body
      })(),
      ...options,
    }),
  delete: (slug: string, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${slug}`, {
      method: "DELETE",
      ...options,
    }),
})

export const courses = defineApiRoute({
  get: (slug: string, pageable: Pageable, options?: BackendFetchOptions) =>
    backend<PageCourseResponse>(
      `/organizations/${slug}/courses${toQueryString(pageable)}`,
      {
        method: "GET",
        ...options,
      }
    ),
  post: async (
    slug: string,
    request: CreateCourseRequest,
    cover?: File,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(`/dashboard/organizations/${slug}/courses`, {
      method: "POST",
      body: (() => {
        const body = new FormData()

        body.set("request", new Blob([JSON.stringify(request)], { type: "application/json" }))
        if (cover) body.set("cover", cover)

        return body
      })(),
      ...options,
    }),
})
