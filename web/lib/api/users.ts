import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { BackendUser } from "@/lib/api/types"

export const me = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<BackendUser>("/users/me", {
      method: "GET",
      ...options,
    }),
})
