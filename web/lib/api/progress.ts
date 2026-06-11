import "server-only"

import { backend } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  SubmitBlockAnswerRequest,
  SubmitBlockAnswerResponse,
} from "@/lib/api/types"

export const submitAnswer = defineApiRoute({
  post: (
    blockId: number,
    request: SubmitBlockAnswerRequest
  ) =>
    backend<SubmitBlockAnswerResponse>(`/blocks/${blockId}/submit`, {
      method: "POST",
      body: request,
    }),
})
