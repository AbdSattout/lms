import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CourseFaqResponse,
  GenerateCourseFaqRequest,
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
    backend<GeneratedQuestionResponse>(
      "/dashboard/ai/questions/from-block-content",
      {
        method: "POST",
        body: request,
        ...options,
      }
    ),
})

export const transformText = defineApiRoute({
  post: (request: GenerateAiTextRequest, options?: BackendFetchOptions) =>
    backend<GeneratedAiTextResponse>("/dashboard/ai/text", {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const generateFaq = defineApiRoute({
  post: (
    courseId: number,
    request: GenerateCourseFaqRequest,
    options?: BackendFetchOptions
  ) =>
    backend<CourseFaqResponse[]>(
      `/dashboard/ai/courses/${courseId}/faq/generate`,
      {
        method: "POST",
        body: request,
        ...options,
      }
    ),
})

export const getFaqs = defineApiRoute({
  get: (courseId: number, options?: BackendFetchOptions) =>
    backend<CourseFaqResponse[]>(`/dashboard/ai/courses/${courseId}/faq`, {
      method: "GET",
      ...options,
    }),
})
