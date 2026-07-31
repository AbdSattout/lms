import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CourseOverviewResponse,
  OrganizationOverviewResponse,
  UserOverviewResponse,
} from "@/lib/api/types"

export const userOverview = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<UserOverviewResponse>("/overview/me", {
      method: "GET",
      ...options,
    }),
})

export const orgOverview = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationOverviewResponse>(`/overview/organizations/${slug}`, {
      method: "GET",
      ...options,
    }),
})

export const courseOverview = defineApiRoute({
  get: (slug: string, courseId: number, options?: BackendFetchOptions) =>
    backend<CourseOverviewResponse>(
      `/overview/organizations/${slug}/courses/${courseId}`,
      { method: "GET", ...options }
    ),
})
