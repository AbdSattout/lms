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
  get: (slug: string, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<Page<PostMediaResponse>>(
      `/dashboard/organizations/${slug}/post-media${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (slug: string, file: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("file", file)

    return backend<PostMediaResponse>(`/dashboard/organizations/${slug}/post-media`, {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const byId = defineApiRoute({
  get: (slug: string, mediaId: number, options?: BackendFetchOptions) =>
    backend<PostMediaResponse>(`/dashboard/organizations/${slug}/post-media/${mediaId}`, {
      method: "GET",
      ...options,
    }),
  patch: (slug: string, mediaId: number, file?: File, name?: string, options?: BackendFetchOptions) => {
    const body = new FormData()

    if (file) body.set("file", file)
    if (name) body.set("name", name)

    return backend<PostMediaResponse>(`/dashboard/organizations/${slug}/post-media/${mediaId}`, {
      method: "PATCH",
      body,
      ...options,
    })
  },
  delete: (slug: string, mediaId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${slug}/post-media/${mediaId}`, {
      method: "DELETE",
      ...options,
    }),
})
