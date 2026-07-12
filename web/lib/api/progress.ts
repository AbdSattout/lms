import "server-only"

import { backend } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { SubmitBlockAnswerResponse } from "@/lib/api/types"
import type { SubmitBlockAnswerInput } from "@/lib/validation"

export const submitAnswer = defineApiRoute({
  post: (
    blockId: number,
    request: SubmitBlockAnswerInput
  ) =>
    backend<SubmitBlockAnswerResponse>(`/blocks/${blockId}/submit`, {
      method: "POST",
      body: request,
    }),
})
