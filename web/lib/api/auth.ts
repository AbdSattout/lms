import "server-only"

import { backend } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { AuthResponse } from "@/lib/api/types"

export const loginWithTelegram = defineApiRoute({
  post: (idToken: string) =>
    backend<AuthResponse>("/auth/login/telegram", {
      method: "POST",
      body: { idToken },
      requireAuth: false,
    }),
})

export const loginWithGoogle = defineApiRoute({
  post: (idToken: string) =>
    backend<AuthResponse>("/auth/login/google", {
      method: "POST",
      body: { idToken },
      requireAuth: false,
    }),
})

export const requestEmailOtp = defineApiRoute({
  post: (email: string) =>
    backend<void>("/auth/login/email/request-otp", {
      method: "POST",
      body: { email },
      requireAuth: false,
    }),
})

export const loginWithEmailOtp = defineApiRoute({
  post: (email: string, otp: string) =>
    backend<AuthResponse>("/auth/login/email/verify-otp", {
      method: "POST",
      body: { email, otp },
      requireAuth: false,
    }),
})

export const loginAdmin = defineApiRoute({
  post: (email: string, password: string) =>
    backend<AuthResponse>("/admin/auth/login", {
      method: "POST",
      body: { email, password },
      requireAuth: false,
    }),
})
