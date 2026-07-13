import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { User, UserSearchResponse } from "@/lib/api/types"
import type { UpdateUserInput } from "@/lib/validation"

export const me = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<User>("/users/me", {
      method: "GET",
      ...options,
    }),
  patch: (request: UpdateUserInput, options?: BackendFetchOptions) =>
    backend<User>("/users/me", {
      method: "PATCH",
      body: request,
      ...options,
    }),
})

export const picture = defineApiRoute({
  patch: (image: File, options?: BackendFetchOptions) => {
    const body = new FormData()

    body.set("image", image)

    return backend<User>("/users/me/picture", {
      method: "PATCH",
      body,
      ...options,
    })
  },
})

export const search = defineApiRoute({
  get: (q: string, options?: BackendFetchOptions) =>
    backend<UserSearchResponse[]>(
      `/users/search?q=${encodeURIComponent(q)}`,
      { method: "GET", ...options }
    ),
})
