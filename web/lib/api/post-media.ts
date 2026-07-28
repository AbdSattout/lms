import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { Page, PostMediaResponse } from "@/lib/api/types"
import type { PageableInput } from "@/lib/validation"

function toQueryString(pageable: PageableInput) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const byOrg = defineApiRoute({
  get: (organizationId: number, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<Page<PostMediaResponse>>(
      `/dashboard/organizations/${organizationId}/post-media${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (organizationId: number, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<PostMediaResponse>(`/dashboard/organizations/${organizationId}/post-media`, {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const byId = defineApiRoute({
  get: (organizationId: number, mediaId: number, options?: BackendFetchOptions) =>
    backend<PostMediaResponse>(`/dashboard/organizations/${organizationId}/post-media/${mediaId}`, {
      method: "GET",
      ...options,
    }),
  patch: (organizationId: number, mediaId: number, file?: File, name?: string, options?: BackendFetchOptions) => {
    const body = new FormData()

    if (file) body.set("file", file)
    if (name) body.set("name", name)

    return backend<PostMediaResponse>(`/dashboard/organizations/${organizationId}/post-media/${mediaId}`, {
      method: "PATCH",
      body,
      ...options,
    })
  },
  delete: (organizationId: number, mediaId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${organizationId}/post-media/${mediaId}`, {
      method: "DELETE",
      ...options,
    }),
})
