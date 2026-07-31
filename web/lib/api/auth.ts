import "server-only"

import { backend } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  AuthResponse,
  LoginRequest,
  EmailOtpRequest,
  VerifyEmailOtpRequest,
} from "@/lib/api/types"

export const loginWithTelegram = defineApiRoute({
  post: (loginRequest: LoginRequest) =>
    backend<AuthResponse>("/auth/login/telegram", {
      method: "POST",
      body: loginRequest,
      requireAuth: false,
    }),
})

export const loginWithGoogle = defineApiRoute({
  post: (loginRequest: LoginRequest) =>
    backend<AuthResponse>("/auth/login/google", {
      method: "POST",
      body: loginRequest,
      requireAuth: false,
    }),
})

export const requestEmailOtp = defineApiRoute({
  post: (request: EmailOtpRequest) =>
    backend<void>("/auth/login/email/request-otp", {
      method: "POST",
      body: request,
      requireAuth: false,
    }),
})

export const verifyEmailOtp = defineApiRoute({
  post: (request: VerifyEmailOtpRequest) =>
    backend<AuthResponse>("/auth/login/email/verify-otp", {
      method: "POST",
      body: request,
      requireAuth: false,
    }),
})
