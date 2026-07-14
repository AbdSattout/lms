import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  RoadmapResponse,
  UpsertRoadmapRequest,
} from "@/lib/api/types"

export const create = defineApiRoute({
  post: (
    slug: string,
    request: UpsertRoadmapRequest,
    options?: BackendFetchOptions
  ) =>
    backend<RoadmapResponse>(`/dashboard/organizations/${slug}/roadmap`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const update = defineApiRoute({
  patch: (
    slug: string,
    request: UpsertRoadmapRequest,
    options?: BackendFetchOptions
  ) =>
    backend<RoadmapResponse>(`/dashboard/organizations/${slug}/roadmap`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})

export const getManageable = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<RoadmapResponse>(`/dashboard/organizations/${slug}/roadmap`, {
      method: "GET",
      ...options,
    }),
})

export const getPublished = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<RoadmapResponse>(`/organizations/${slug}/roadmap`, {
      method: "GET",
      requireAuth: false,
      ...options,
    }),
})
