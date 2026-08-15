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
  try {
    const data = await api.dashboard.posts.byOrg.post(orgSlug, input)

    revalidatePath(`/${orgSlug}/posts`)
    if (input.courseId) {
      revalidatePath(`/${orgSlug}/courses/${input.courseId}/posts`)
    }
    return {
      success: true,
      data,
      error: null,
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error)

    return {
      success: false,
      data: null,
      error: errorMessage,
    }
  }
}
export async function likePost(
  postId: number,
  reactionType?: Parameters<typeof api.dashboard.posts.likes.post>[1]
) {
  return api.dashboard.posts.likes.post(postId, reactionType)
}

export async function unlikePost(postId: number) {
  return api.dashboard.posts.likes.delete(postId)
}
export async function updatePost(
  orgSlug: string,
  postId: number,
  input: UpdatePostInput
) {
  try {
    const post = await api.dashboard.posts.byId.patch(postId, input)

    revalidatePath(`/${orgSlug}/posts`)

    revalidatePath(`/${orgSlug}/posts/${postId}`)

    revalidatePath(`/${orgSlug}/posts/${postId}/edit`)

    return post
  } catch (error) {
    console.error("[SERVER ACTION ERROR - updatePost]:", error)

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
export async function likeComment(
  commentId: number,
  reactionType?: "LIKE" | "LOVE" | "SUPPORT" | "CELEBRATE" | "INSIGHTFUL"
) {
  return api.dashboard.posts.commentLikes.post(commentId, reactionType)
}

export async function unlikeComment(commentId: number) {
  return api.dashboard.posts.commentLikes.delete(commentId)
}
export async function deleteComment(commentId: number) {
  return api.dashboard.posts.deleteComment.delete(commentId)
}
export async function getPostsByOrg(slug: string, pageable: PageableInput) {
  return api.dashboard.posts.byOrg.get(slug, pageable)
}

export async function getPostById(postId: number, slug: string) {
  return api.dashboard.posts.byId.get(slug, postId)
}
export async function getPostsByCourse(
  courseId: number,
  pageable: PageableInput
) {
  return api.dashboard.posts.byCourse.get(courseId, pageable)
}
export async function getCoursePostById(courseId: number, postId: number) {
  return api.dashboard.posts.coursePostById.get(courseId, postId)
}
export async function getCommentsByPost(postId: number) {
  return api.dashboard.posts.comments.get(postId)
}
