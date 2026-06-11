import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  QuestionResponse,
  UpdateQuestionRequest,
} from "@/lib/api/types"

export const update = defineApiRoute({
  patch: (
    questionId: number,
    request: UpdateQuestionRequest,
    options?: BackendFetchOptions
  ) =>
    backend<QuestionResponse>(`/questions/${questionId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
})
