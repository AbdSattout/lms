import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  BlockPublicResponse,
  BlockResponse,
} from "@/lib/api/types"
import type {
  CreateBlockInput,
  ReorderBlocksInput,
  UpdateBlockInput,
} from "@/lib/validation"

export const create = defineApiRoute({
  post: (
    lessonId: number,
    request: CreateBlockInput,
    options?: BackendFetchOptions
  ) =>
    backend<BlockResponse>(`/dashboard/lessons/${lessonId}/blocks`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const reorder = defineApiRoute({
  patch: (
    lessonId: number,
    request: ReorderBlocksInput,
    options?: BackendFetchOptions
  ) =>
    backend<void>(`/dashboard/lessons/${lessonId}/blocks/reorder`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})

export const byId = defineApiRoute({
  get: (blockId: number, options?: BackendFetchOptions) =>
    backend<BlockResponse>(`/dashboard/blocks/${blockId}`, {
      method: "GET",
      ...options,
    }),
  patch: (
    blockId: number,
    request: UpdateBlockInput,
    options?: BackendFetchOptions
  ) =>
    backend<BlockResponse>(`/dashboard/blocks/${blockId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (blockId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/blocks/${blockId}`, {
      method: "DELETE",
      ...options,
    }),
})

export const getPublic = defineApiRoute({
  get: (blockId: number, options?: BackendFetchOptions) =>
    backend<BlockPublicResponse>(`/blocks/${blockId}`, {
      method: "GET",
      ...options,
    }),
})
