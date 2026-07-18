"use server"

import { api } from "@/lib/api"
import type {
  CreateCommentInput,
  CreatePostInput,
  PageableInput,
  UpdatePostInput,
} from "@/lib/validation"
import { revalidatePath } from "next/cache"

export async function createPost(orgSlug: string, input: CreatePostInput) {
  const post = await api.dashboard.posts.byOrg.post(orgSlug, input)
  revalidatePath(`/${orgSlug}/posts`)
  return post
}

export async function updatePost(postId: number, input: UpdatePostInput) {
  return api.dashboard.posts.byId.patch(postId, input)
}

export async function deletePost(postId: number, orgSlug: string) {
  await api.dashboard.posts.byId.delete(postId)
  revalidatePath(`/${orgSlug}/posts`)
}

export async function createComment(postId: number, input: CreateCommentInput) {
  return api.dashboard.posts.comments.post(postId, input)
}

export async function deleteComment(commentId: number) {
  return api.dashboard.posts.deleteComment.delete(commentId)
}
export async function getPostsByOrg(slug: string, pageable: PageableInput) {
  return api.dashboard.posts.byOrg.get(slug, pageable)
}

export async function getPostById(postId: number) {
  return api.dashboard.posts.byId.get(postId)
}

export async function getCommentsByPost(postId: number) {
  return api.dashboard.posts.comments.get(postId)
}
