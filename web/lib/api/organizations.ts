import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CourseResponse,
  OrganizationResponse,
} from "@/lib/api/types"
import type {
  CreateCourseInput,
  CreateOrganizationInput,
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
