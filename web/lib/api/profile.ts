import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { ProfileResponse } from "@/lib/api/types"
import type { CreateProfileInput, UpdateProfileInput } from "@/lib/validation"

export const create = defineApiRoute({
  post: (request: CreateProfileInput) =>
    backend<ProfileResponse>("/profile", {
      method: "POST",
      body: request,
    }),
})

export const me = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<ProfileResponse>("/profile/me", {
      method: "GET",
      ...options,
    }),
  patch: (request: UpdateProfileInput, options?: BackendFetchOptions) =>
    backend<ProfileResponse>("/profile/me", {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (options?: BackendFetchOptions) =>
    backend<string>("/profile/me", {
      method: "DELETE",
      ...options,
    }),
})
