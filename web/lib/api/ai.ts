import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  GenerateQuestionFromBlockContentRequest,
  GeneratedQuestionResponse,
  GenerateAiTextRequest,
  GeneratedAiTextResponse,
} from "@/lib/api/types"

export const generateQuestionFromBlock = defineApiRoute({
  post: (
    request: GenerateQuestionFromBlockContentRequest,
    options?: BackendFetchOptions
  ) =>
    backend<GeneratedQuestionResponse>("/dashboard/ai/questions/from-block-content", {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const transformText = defineApiRoute({
  post: (
    request: GenerateAiTextRequest,
    options?: BackendFetchOptions
  ) =>
    backend<GeneratedAiTextResponse>("/dashboard/ai/text", {
      method: "POST",
      body: request,
      ...options,
    }),
})
