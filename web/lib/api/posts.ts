import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type {
  CommentResponse,
  CreateCommentRequest,
  CreatePostRequest,
  PagePostResponse,
  Pageable,
  PostResponse,
  UpdatePostRequest,
} from "@/lib/api/types"

function toQueryString(pageable: Pageable) {
  const params = new URLSearchParams()

  if (pageable.page !== undefined) params.set("page", String(pageable.page))
  if (pageable.size !== undefined) params.set("size", String(pageable.size))
  for (const sort of pageable.sort ?? []) params.append("sort", sort)

  const query = params.toString()
  return query ? `?${query}` : ""
}

export const byCourse = defineApiRoute({
  get: (
    courseId: number,
    pageable: Pageable,
    options?: BackendFetchOptions
  ) =>
    backend<PagePostResponse>(
      `/dashboard/courses/${courseId}/posts${toQueryString(pageable)}`,
      { method: "GET", ...options }
    ),
  post: (
    courseId: number,
    request: CreatePostRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PostResponse>(`/dashboard/courses/${courseId}/posts`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const byId = defineApiRoute({
  get: (postId: number, options?: BackendFetchOptions) =>
    backend<PostResponse>(`/dashboard/posts/${postId}`, {
      method: "GET",
      ...options,
    }),
  patch: (
    postId: number,
    request: UpdatePostRequest,
    options?: BackendFetchOptions
  ) =>
    backend<PostResponse>(`/dashboard/posts/${postId}`, {
      method: "PATCH",
      body: request,
      ...options,
    }),
  delete: (postId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/posts/${postId}`, {
      method: "DELETE",
      ...options,
    }),
})

export const likes = defineApiRoute({
  post: (postId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/posts/${postId}/likes`, {
      method: "POST",
      ...options,
    }),
  delete: (postId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/posts/${postId}/likes`, {
      method: "DELETE",
      ...options,
    }),
})

export const comments = defineApiRoute({
  get: (postId: number, options?: BackendFetchOptions) =>
    backend<CommentResponse[]>(`/dashboard/posts/${postId}/comments`, {
      method: "GET",
      ...options,
    }),
  post: (
    postId: number,
    request: CreateCommentRequest,
    options?: BackendFetchOptions
  ) =>
    backend<CommentResponse>(`/dashboard/posts/${postId}/comments`, {
      method: "POST",
      body: request,
      ...options,
    }),
})

export const deleteComment = defineApiRoute({
  delete: (commentId: number, options?: BackendFetchOptions) =>
    backend<void>(`/dashboard/comments/${commentId}`, {
      method: "DELETE",
      ...options,
    }),
})
