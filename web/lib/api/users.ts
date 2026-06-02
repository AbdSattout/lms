import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { User } from "@/lib/api/types"

export const me = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<User>("/users/me", {
      method: "GET",
      ...options,
    }),
})
