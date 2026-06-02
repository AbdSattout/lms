import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CreateProfileRequest,
  ProfileResponse,
  UpdateProfile,
} from "@/lib/api/types"

export const create = defineApiRoute({
  post: (request: CreateProfileRequest) =>
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
  patch: (request: UpdateProfile, options?: BackendFetchOptions) =>
    backend<ProfileResponse>("/profile/me", {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (options?: BackendFetchOptions) =>
    backend<void>("/profile/me", {
      method: "DELETE",
      ...options,
    }),
})
