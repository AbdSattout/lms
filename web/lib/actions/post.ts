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

export async function updatePost(
  orgSlug: string,
  postId: number,
  input: UpdatePostInput
) {
  try {
    const post = await api.dashboard.posts.byId.patch(postId, input)

    // 1. Revalidate the posts list page
    revalidatePath(`/${orgSlug}/posts`)

    // 2. Revalidate the individual post view page
    revalidatePath(`/${orgSlug}/posts/${postId}`)

    // 3. Revalidate the edit page (in case the user returns to it later, they get the freshest data)
    revalidatePath(`/${orgSlug}/posts/${postId}/edit`)

    // You can also use layout revalidation to sweep all nested paths in one line if preferred:
    // revalidatePath(`/${orgSlug}/posts`, 'layout')

    return post
  } catch (error) {
    // Log the error securely on your server so you know exactly why it failed
    console.error("[SERVER ACTION ERROR - updatePost]:", error)

    // Throw an error string so your Frontend Try/Catch in the form detects the failure correctly!
    throw new Error("فشل تعديل المنشور. تحقق من البيانات المدخلة.")
  }
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
