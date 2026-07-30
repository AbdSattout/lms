import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  OrganizationDashboardResponse,
  UserDashboardResponse,
} from "@/lib/api/types"

export const userDashboard = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<UserDashboardResponse>("/dashboard/details/me", {
      method: "GET",
      ...options,
    }),
})

export const organizationDashboard = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationDashboardResponse>(
      `/dashboard/details/organizations/${slug}`,
      { method: "GET", ...options }
    ),
})
