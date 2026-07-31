import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CheckoutSessionResponse,
  CustomerPortalSessionResponse,
} from "@/lib/api/types"

export const checkout = defineApiRoute({
  post: (options?: BackendFetchOptions) =>
    backend<CheckoutSessionResponse>("/billing/checkout", {
      method: "POST",
      ...options,
    }),
})

export const portal = defineApiRoute({
  post: (options?: BackendFetchOptions) =>
    backend<CustomerPortalSessionResponse>("/billing/portal", {
      method: "POST",
      ...options,
    }),
})

export const revoke = defineApiRoute({
  post: (options?: BackendFetchOptions) =>
    backend<void>("/billing/revoke", {
      method: "POST",
      ...options,
    }),
})
