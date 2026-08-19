import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  AdminResponse,
  BannedOrganizationResponse,
  BannedUserResponse,
  BanRequest,
  CommentResponse,
  CourseResponse,
  CreateModeratorRequest,
  OrganizationResponse,
  OrganizationVerificationResponse,
  OrganizationVerificationStatus,
  Page,
  PageBannedUserResponse,
  PageModeratorResponse,
  PageOrganizationVerificationResponse,
  PostResponse,
  ProfileResponse,
  ReportPageResponse,
  ReportResponse,
  ReportReviewRequest,
  ReportStatus,
  ReviewOrganizationVerificationRequest,
  UserResponse,
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

export const organizationVerifications = {
  list: defineApiRoute({
    get: (
      status: OrganizationVerificationStatus | undefined,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) => {
      const params = new URLSearchParams()

      if (status) {
        params.set("status", status)
      }

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

      return backend<PageOrganizationVerificationResponse>(
        `/admin/organization-verifications${query ? `?${query}` : ""}`,
        {
          method: "GET",
          ...options,
        }
      )
    },
  }),

  byId: defineApiRoute({
    get: (requestId: number, options?: BackendFetchOptions) =>
      backend<OrganizationVerificationResponse>(
        `/admin/organization-verifications/${requestId}`,
        { method: "GET", ...options }
      ),
  }),

  review: defineApiRoute({
    patch: (
      requestId: number,
      request: ReviewOrganizationVerificationRequest,
      options?: BackendFetchOptions
    ) =>
      backend<OrganizationVerificationResponse>(
        `/admin/organization-verifications/${requestId}`,
        {
          method: "PATCH",
          body: request,
          ...options,
        }
      ),
  }),
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
  get: (userId: number, options?: BackendFetchOptions) =>
    backend<ProfileResponse>(`/admin/users/${userId}`, {
      method: "GET",
      ...options,
    }),
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

export const moderation = {
  users: {
    list: defineApiRoute({
      get: (
        q: string | undefined,
        pageable: PageableInput,
        options?: BackendFetchOptions
      ) => {
        const query = new URLSearchParams()

        if (q?.trim()) {
          query.set("q", q.trim())
        }

        if (pageable.page !== undefined) {
          query.set("page", String(pageable.page))
        }

        if (pageable.size !== undefined) {
          query.set("size", String(pageable.size))
        }

        for (const sort of pageable.sort ?? []) {
          query.append("sort", sort)
        }

        const queryString = query.toString()

        return backend<Page<UserResponse>>(
          `/admin/users${queryString ? `?${queryString}` : ""}`,
          {
            method: "GET",
            ...options,
          }
        )
      },
    }),

    banned: defineApiRoute({
      get: (pageable: PageableInput, options?: BackendFetchOptions) =>
        backend<Page<BannedUserResponse>>(
          withPageable("/admin/moderation/users/banned", pageable),
          {
            method: "GET",
            ...options,
          }
        ),
    }),

    ban: defineApiRoute({
      post: (
        userId: number,
        request: BanRequest,
        options?: BackendFetchOptions
      ) =>
        backend<void>(`/admin/moderation/users/${userId}/ban`, {
          method: "POST",
          body: request,
          ...options,
        }),
    }),

    unban: defineApiRoute({
      delete: (userId: number, options?: BackendFetchOptions) =>
        backend<void>(`/admin/moderation/users/${userId}/ban`, {
          method: "DELETE",
          ...options,
        }),
    }),
  },

  organizations: {
    list: defineApiRoute({
      get: (
        q: string | undefined,
        pageable: PageableInput,
        options?: BackendFetchOptions
      ) => {
        const query = new URLSearchParams()

        if (q?.trim()) {
          query.set("q", q.trim())
        }

        if (pageable.page !== undefined) {
          query.set("page", String(pageable.page))
        }

        if (pageable.size !== undefined) {
          query.set("size", String(pageable.size))
        }

        for (const sort of pageable.sort ?? []) {
          query.append("sort", sort)
        }

        const queryString = query.toString()

        return backend<Page<OrganizationResponse>>(
          `/admin/organizations${queryString ? `?${queryString}` : ""}`,
          {
            method: "GET",
            ...options,
          }
        )
      },
    }),

    banned: defineApiRoute({
      get: (pageable: PageableInput, options?: BackendFetchOptions) =>
        backend<Page<BannedOrganizationResponse>>(
          withPageable("/admin/moderation/organizations/banned", pageable),
          {
            method: "GET",
            ...options,
          }
        ),
    }),

    ban: defineApiRoute({
      post: (
        organizationId: number,
        request: BanRequest,
        options?: BackendFetchOptions
      ) =>
        backend<void>(`/admin/moderation/organizations/${organizationId}/ban`, {
          method: "POST",
          body: request,
          ...options,
        }),
    }),

    unban: defineApiRoute({
      delete: (organizationId: number, options?: BackendFetchOptions) =>
        backend<void>(`/admin/moderation/organizations/${organizationId}/ban`, {
          method: "DELETE",
          ...options,
        }),
    }),
  },
}
export const moderators = {
  me: defineApiRoute({
    get: (options?: BackendFetchOptions) =>
      backend<AdminResponse>("/admin/moderators/me", {
        method: "GET",
        ...options,
      }),
  }),
  list: defineApiRoute({
    get: (pageable: PageableInput, options?: BackendFetchOptions) =>
      backend<PageModeratorResponse>(
        withPageable("/admin/moderators", pageable),
        {
          method: "GET",
          ...options,
        }
      ),
  }),

  create: defineApiRoute({
    post: (request: CreateModeratorRequest, options?: BackendFetchOptions) =>
      backend<AdminResponse>("/admin/moderators", {
        method: "POST",
        body: request,
        ...options,
      }),
  }),

  remove: defineApiRoute({
    delete: (moderatorId: number, options?: BackendFetchOptions) =>
      backend<void>(`/admin/moderators/${moderatorId}`, {
        method: "DELETE",
        ...options,
      }),
  }),
}
