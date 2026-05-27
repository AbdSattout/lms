import "server-only"

import { backend } from "@/lib/api/backend"
import type { BackendAuthLoginResponse } from "@/lib/api/types"

export async function loginWithOidcIdToken(idToken: string) {
  return backend<BackendAuthLoginResponse>("/auth/login", {
    method: "POST",
    body: { idToken },
    requireAuth: false,
  })
}
