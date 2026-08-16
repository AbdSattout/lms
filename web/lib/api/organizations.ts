import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  BanRequest,
  CourseResponse,
  CreateInviteRequest,
  CreatePublicInviteRequest,
  JoinRequestResponse,
  OrganizationInviteResponse,
  OrganizationResponse,
  OrganizationUserSearchResponse,
  PageOrganizationBanResponse,
  PageOrganizationMemberResponse,
  UpdateInviteCapacityRequest,
} from "@/lib/api/types"
import type {
  CreateCourseInput,
  CreateOrganizationInput,
  PageableInput,
  UpdateOrganizationInput,
} from "@/lib/validation"

export const list = defineApiRoute({
  get: (options?: BackendFetchOptions) =>
    backend<OrganizationResponse[]>("/dashboard/organizations", {
      method: "GET",
      ...options,
    }),
})

export const create = defineApiRoute({
  post: (
    request: CreateOrganizationInput,
    image?: File,
    options?: BackendFetchOptions
  ) => {
    const body = new FormData()

    body.set(
      "request",
      new Blob([JSON.stringify(request)], { type: "application/json" })
    )
    if (image) body.set("image", image)

    return backend<OrganizationResponse>("/dashboard/organizations", {
      method: "POST",
      body,
      ...options,
    })
  },
})

export const bySlug = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<OrganizationResponse>(`/dashboard/organizations/${slug}`, {
      method: "GET",
      ...options,
    }),
  patch: async (
    slug: string,
    request: UpdateOrganizationInput,
    image?: File,
    options?: BackendFetchOptions
  ) =>
    backend<OrganizationResponse>(`/dashboard/organizations/${slug}`, {
      method: "PATCH",
      body: (() => {
        const body = new FormData()

        body.set(
          "request",
          new Blob([JSON.stringify(request)], { type: "application/json" })
        )
        if (image) body.set("image", image)

        return body
      })(),
      ...options,
    }),
  delete: (slug: string, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${slug}`, {
      method: "DELETE",
      ...options,
    }),
})

export const checkSlugAvailability = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<boolean>(
      `/dashboard/organizations/check-availability?slug=${encodeURIComponent(slug)}`,
      {
        method: "GET",
        ...options,
      }
    ),
})

export const courses = defineApiRoute({
  get: (slug: string, options?: BackendFetchOptions) =>
    backend<CourseResponse[]>(`/dashboard/organizations/${slug}/courses`, {
      method: "GET",
      ...options,
    }),
  post: async (
    slug: string,
    request: CreateCourseInput,
    cover?: File,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(`/dashboard/organizations/${slug}/courses`, {
      method: "POST",
      body: (() => {
        const body = new FormData()

        body.set(
          "request",
          new Blob([JSON.stringify(request)], { type: "application/json" })
        )
        if (cover) body.set("cover", cover)

        return body
      })(),
      ...options,
    }),
})

export const getCourseBySlug = defineApiRoute({
  get: (
    organizationSlug: string,
    courseSlug: string,
    options?: BackendFetchOptions
  ) =>
    backend<CourseResponse>(
      `/dashboard/organizations/${organizationSlug}/courses/${courseSlug}`,
      { method: "GET", ...options }
    ),
})

export const checkCourseSlugAvailability = defineApiRoute({
  get: (slug: string, courseSlug: string, options?: BackendFetchOptions) =>
    backend<boolean>(
      `/dashboard/organizations/${slug}/courses/check-slug?courseSlug=${encodeURIComponent(courseSlug)}`,
      { method: "GET", ...options }
    ),
})

function toQueryString(pageable: PageableInput) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const leave = defineApiRoute({
  post: (slug: string, options?: BackendFetchOptions) =>
    backend<void>(`/organizations/${slug}/leave`, {
      method: "DELETE",
      ...options,
    }),
})
export const invites = {
  create: defineApiRoute({
    post: (
      slug: string,
      request: CreateInviteRequest,
      options?: BackendFetchOptions
    ) =>
      backend<OrganizationInviteResponse>(
        `/dashboard/organizations/${slug}/invites`,
        {
          method: "POST",
          body: request,
          ...options,
        }
      ),
  }),
  createPublic: defineApiRoute({
    post: (
      slug: string,
      request: CreatePublicInviteRequest,
      options?: BackendFetchOptions
    ) =>
      backend<OrganizationInviteResponse>(
        `/dashboard/organizations/${slug}/invites/public`,
        {
          method: "POST",
          body: request,
          ...options,
        }
      ),
  }),
  list: defineApiRoute({
    get: (slug: string, options?: BackendFetchOptions) =>
      backend<OrganizationInviteResponse[]>(
        `/dashboard/organizations/${slug}/invites`,
        {
          method: "GET",
          ...options,
        }
      ),
  }),
  accept: defineApiRoute({
    post: (slug: string, inviteId: number, options?: BackendFetchOptions) =>
      backend<void>(`/organizations/${slug}/invites/${inviteId}/accept`, {
        method: "POST",
        ...options,
      }),
  }),

  decline: defineApiRoute({
    post: (slug: string, inviteId: number, options?: BackendFetchOptions) =>
      backend<void>(`/organizations/${slug}/invites/${inviteId}/decline`, {
        method: "POST",
        ...options,
      }),
  }),
  getMyInvites: defineApiRoute({
    get: (options?: BackendFetchOptions) =>
      backend<OrganizationInviteResponse[]>(
        `/dashboard/organizations/invites/my-invites`,
        {
          method: "GET",
          ...options,
        }
      ),
  }),
  resend: defineApiRoute({
    post: (slug: string, inviteId: number, options?: BackendFetchOptions) =>
      backend<OrganizationInviteResponse>(
        `/dashboard/organizations/${slug}/invites/${inviteId}/resend`,
        {
          method: "POST",
          ...options,
        }
      ),
  }),
  cancel: defineApiRoute({
    post: (slug: string, inviteId: number, options?: BackendFetchOptions) =>
      backend<void>(
        `/dashboard/organizations/${slug}/invites/${inviteId}/cancel`,
        {
          method: "POST",
          ...options,
        }
      ),
  }),
  updateCapacity: defineApiRoute({
    patch: (
      slug: string,
      inviteId: number,
      request: UpdateInviteCapacityRequest,
      options?: BackendFetchOptions
    ) =>
      backend<OrganizationInviteResponse>(
        `/dashboard/organizations/${slug}/invites/${inviteId}/capacity`,
        {
          method: "PATCH",
          body: request,
          ...options,
        }
      ),
  }),
}

function withPageable(path: string, pageable: PageableInput) {
  return `${path}${toQueryString(pageable)}`
}

export const members = {
  list: defineApiRoute({
    get: (
      slug: string,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<PageOrganizationMemberResponse>(
        withPageable(`/dashboard/organizations/${slug}/members`, pageable),
        { method: "GET", ...options }
      ),
  }),
  owners: defineApiRoute({
    get: (
      slug: string,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<PageOrganizationMemberResponse>(
        withPageable(
          `/dashboard/organizations/${slug}/members/owners`,
          pageable
        ),
        { method: "GET", ...options }
      ),
  }),
  admins: defineApiRoute({
    get: (
      slug: string,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<PageOrganizationMemberResponse>(
        withPageable(
          `/dashboard/organizations/${slug}/members/admins`,
          pageable
        ),
        { method: "GET", ...options }
      ),
  }),
  students: defineApiRoute({
    get: (
      slug: string,
      pageable: PageableInput,
      options?: BackendFetchOptions
    ) =>
      backend<PageOrganizationMemberResponse>(
        withPageable(
          `/dashboard/organizations/${slug}/members/students`,
          pageable
        ),
        { method: "GET", ...options }
      ),
  }),
}

export const searchUsers = defineApiRoute({
  get: (slug: string, q: string, options?: BackendFetchOptions) =>
    backend<OrganizationUserSearchResponse[]>(
      `/dashboard/organizations/${slug}/users/search?q=${encodeURIComponent(q)}`,
      { method: "GET", ...options }
    ),
})

export const removeMember = defineApiRoute({
  delete: (slug: string, userId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/organizations/${slug}/members/${userId}`, {
      method: "DELETE",
      ...options,
    }),
})

export const banUser = defineApiRoute({
  get: (slug: string, pageable: PageableInput, options?: BackendFetchOptions) =>
    backend<PageOrganizationBanResponse>(
      withPageable(`/dashboard/organizations/${slug}/users/banned`, pageable),
      { method: "GET", ...options }
    ),
  post: (
    slug: string,
    userId: number,
    request: BanRequest,
    options?: BackendFetchOptions
  ) =>
    backend<void>(`/dashboard/organizations/${slug}/users/${userId}/ban`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const unbanUser = defineApiRoute({
  delete: (userId: number, options?: BackendFetchOptions) =>
    backend<void>(`/admin/moderation/users/${userId}/ban`, {
      method: "DELETE",
      ...options,
    }),
})

export const adminBanOrg = defineApiRoute({
  post: (orgId: number, request: BanRequest, options?: BackendFetchOptions) =>
    backend<void>(`/admin/moderation/organizations/${orgId}/ban`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const joinRequests = {
  create: defineApiRoute({
    post: (slug: string, options?: BackendFetchOptions) =>
      backend<JoinRequestResponse>(`/organizations/${slug}/join`, {
        method: "POST",
        ...options,
      }),
  }),
  cancel: defineApiRoute({
    delete: (slug: string, options?: BackendFetchOptions) =>
      backend<void>(`/organizations/${slug}/join-request`, {
        method: "DELETE",
        ...options,
      }),
  }),
  dashboard: {
    listPending: defineApiRoute({
      get: (slug: string, options?: BackendFetchOptions) =>
        backend<JoinRequestResponse[]>(
          `/dashboard/organizations/${slug}/join-requests`,
          {
            method: "GET",
            ...options,
          }
        ),
    }),
    accept: defineApiRoute({
      post: (slug: string, id: number, options?: BackendFetchOptions) =>
        backend<void>(
          `/dashboard/organizations/${slug}/join-requests/${id}/accept`,
          {
            method: "POST",
            ...options,
          }
        ),
    }),
    reject: defineApiRoute({
      post: (slug: string, id: number, options?: BackendFetchOptions) =>
        backend<void>(
          `/dashboard/organizations/${slug}/join-requests/${id}/reject`,
          {
            method: "POST",
            ...options,
          }
        ),
    }),
  },
}
