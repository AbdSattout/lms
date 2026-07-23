import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  Page,
  RoadmapResponse,
  UpsertRoadmapRequest,
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

export const create = defineApiRoute({
  post: (
    slug: string,
    request: UpsertRoadmapRequest,
    options?: BackendFetchOptions
  ) =>
    backend<RoadmapResponse>(`/dashboard/organizations/${slug}/roadmaps`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const list = defineApiRoute({
  get: (slug: string, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<Page<RoadmapResponse>>(
      `/dashboard/organizations/${slug}/roadmaps${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
})

export const byId = defineApiRoute({
  get: (slug: string, roadmapId: number, options?: BackendFetchOptions) =>
    backend<RoadmapResponse>(
      `/dashboard/organizations/${slug}/roadmaps/${roadmapId}`,
      {
        method: "GET",
        ...options,
      }
    ),
  patch: (
    slug: string,
    roadmapId: number,
    request: UpsertRoadmapRequest,
    options?: BackendFetchOptions
  ) =>
    backend<RoadmapResponse>(
      `/dashboard/organizations/${slug}/roadmaps/${roadmapId}`,
      {
        method: "PATCH",
        body: request,
        ...options,
      }
    ),
  delete: (slug: string, roadmapId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${slug}/roadmaps/${roadmapId}`, {
      method: "DELETE",
      ...options,
    }),
})
