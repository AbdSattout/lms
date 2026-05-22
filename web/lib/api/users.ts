import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import type { BackendUser } from "@/lib/api/types"

export async function me(options?: BackendFetchOptions) {
  return backend<BackendUser>("/users/me", {
    method: "GET",
    ...options,
  })
}
