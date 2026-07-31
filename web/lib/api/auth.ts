import "server-only"

import { backend } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { AuthResponse } from "@/lib/api/types"

export const login = defineApiRoute({
  post: (idToken: string) =>
    backend<AuthResponse>("/auth/login", {
      method: "POST",
      body: { idToken },
      requireAuth: false,
    }),
})
