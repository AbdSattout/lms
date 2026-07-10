import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { ChapterResponse } from "@/lib/api/types"
import type { UpdateChapterInput } from "@/lib/validation"

export const byId = defineApiRoute({
  delete: (chapterId: number, options?: BackendFetchOptions) =>
    backend<void>(`/chapters/${chapterId}`, {
      method: "DELETE",
      ...options,
    }),
  patch: (
    chapterId: number,
    request: UpdateChapterInput,
    options?: BackendFetchOptions
  ) =>
    backend<ChapterResponse>(`/chapters/${chapterId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})
