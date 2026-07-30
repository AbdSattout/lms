import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  OrganizationMediaResponse,
  OrganizationMediaSummaryResponse,
  Page,
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

export const list = defineApiRoute({
  get: (organizationId: number, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<Page<OrganizationMediaResponse>>(
      `/dashboard/organizations/${organizationId}/media-library${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
})

export const summary = defineApiRoute({
  get: (organizationId: number, options?: BackendFetchOptions) =>
    backend<OrganizationMediaSummaryResponse>(
      `/dashboard/organizations/${organizationId}/media-library/summary`,
      { method: "GET", ...options }
    ),
})
