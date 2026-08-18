import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CommentResponse,
  CourseResponse,
  OrganizationResponse,
  PostResponse,
  ReportPageResponse,
  ReportResponse,
  ReportReviewRequest,
  ReportStatus,
} from "@/lib/api/types"
import type { PageableInput } from "@/lib/validation"

function toQueryString(pageable: PageableInput) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) {
    params.set("page", String(pageable.page))
  }

  if (pageable.size !== undefined) {
    params.set("size", String(pageable.size))
  }

  for (const sort of pageable.sort ?? []) {
    params.append("sort", sort)
  }

  const query = params.toString()
  return query ? `?${query}` : ""
}

function withPageable(path: string, pageable: PageableInput) {
  return `${path}${toQueryString(pageable)}`
}

export const reports = {
  list: defineApiRoute({
    get: (pageable: PageableInput, options?: BackendFetchOptions) =>
      backend<ReportPageResponse>(withPageable("/admin/reports", pageable), {
        method: "GET",
        ...options,
      }),
  }),

  byStatus: defineApiRoute({
    get: (
      status: ReportStatus,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<ReportPageResponse>(
        withPageable(`/admin/reports/status/${status}`, pageable),
        {
          method: "GET",
          ...options,
        }
      ),
  }),

  review: defineApiRoute({
    patch: (
      reportId: number,
      request: ReportReviewRequest,
      options?: BackendFetchOptions
    ) =>
      backend<ReportResponse>(`/admin/reports/${reportId}`, {
        method: "PATCH",
        body: request,
        ...options,
      }),
  }),
}

export const organizations = {
  get: (organizationId: number, options?: BackendFetchOptions) =>
    backend<OrganizationResponse>(`/admin/organizations/${organizationId}`, {
      method: "GET",
      ...options,
    }),

  courses: defineApiRoute({
    get: (
      organizationId: number,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<{
        content: CourseResponse[]
        totalElements: number
        totalPages: number
      }>(
        withPageable(
          `/admin/organizations/${organizationId}/courses`,
          pageable
        ),
        {
          method: "GET",
          ...options,
        }
      ),
  }),
  posts: defineApiRoute({
    get: (
      organizationId: number,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<{
        content: PostResponse[]
        totalElements: number
        totalPages: number
      }>(
        withPageable(`/admin/organizations/${organizationId}/posts`, pageable),
        {
          method: "GET",
          ...options,
        }
      ),
  }),

  post: defineApiRoute({
    get: (
      organizationId: number,
      postId: number,
      options?: BackendFetchOptions
    ) =>
      backend<PostResponse>(
        `/admin/organizations/${organizationId}/posts/${postId}`,
        {
          method: "GET",
          ...options,
        }
      ),
  }),
}
export const comments = {
  get: (commentId: number, options?: BackendFetchOptions) =>
    backend<CommentResponse>(`/admin/comments/${commentId}`, {
      method: "GET",
      ...options,
    }),
}
export const users = {
  posts: defineApiRoute({
    get: (
      userId: number,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<{
        content: PostResponse[]
        totalElements: number
        totalPages: number
      }>(withPageable(`/admin/users/${userId}/posts`, pageable), {
        method: "GET",
        ...options,
      }),
  }),

  comments: defineApiRoute({
    get: (
      userId: number,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<{
        content: CommentResponse[]
        totalElements: number
        totalPages: number
      }>(withPageable(`/admin/users/${userId}/comments`, pageable), {
        method: "GET",
        ...options,
      }),
  }),
}
