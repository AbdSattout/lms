import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { OrganizationOverviewResponse } from "@/lib/api/types"

export const overview = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationOverviewResponse>(`/overview/organizations/${slug}`, {
      method: "GET",
      ...options,
    }),
})
