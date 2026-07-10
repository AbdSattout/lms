import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { QuestionResponse } from "@/lib/api/types"
import type { UpdateQuestionInput } from "@/lib/validation"

export const update = defineApiRoute({
  patch: (
    questionId: number,
    request: UpdateQuestionInput,
    options?: BackendFetchOptions
  ) =>
    backend<QuestionResponse>(`/questions/${questionId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})
