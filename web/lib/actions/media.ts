"use server"

import { api } from "@/lib/api"
import type {
  CourseMediaResponse,
  Page,
  PageCourseMediaResponse,
  PostMediaResponse,
} from "@/lib/api/types"
import { revalidatePath } from "next/cache"

/* ───── Post media (org-level) ───── */

export async function fetchPostMediaAction(
  slug: string,
  page: number,
  size: number
): Promise<Page<PostMediaResponse>> {
  return api.dashboard.postMedia.byOrg.get(slug, { page, size })
}

export async function uploadPostMediaAction(
  orgSlug: string,
  file: File
): Promise<{ error?: string; media?: PostMediaResponse }> {
  const media = await api.dashboard.postMedia.byOrg
    .post(orgSlug, file)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء رفع الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return { media }
}

export async function updatePostMediaAction(
  slug: string,
  mediaId: number,
  data: { name?: string; file?: File }
): Promise<{ error?: string; media?: PostMediaResponse }> {
  const media = await api.dashboard.postMedia.byId
    .patch(slug, mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${slug}/media`)
  return { media }
}

export async function getPostMediaByIdAction(
  slug: string,
  mediaId: number
): Promise<PostMediaResponse | null> {
  return api.dashboard.postMedia.byId.get(slug, mediaId).catch(() => null)
}

export async function deletePostMediaAction(
  slug: string,
  mediaId: number
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.postMedia.byId
    .delete(slug, mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${slug}/media`)
  return {}
}

/* ───── Course media ───── */

export async function fetchCourseMediaAction(
  orgSlug: string,
  courseSlug: string,
  page: number,
  size: number
): Promise<PageCourseMediaResponse> {
  return api.dashboard.media.byCourse.get(orgSlug, courseSlug, { page, size })
}

export async function uploadCourseMediaAction(
  orgSlug: string,
  courseSlug: string,
  file: File
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byCourse
    .post(orgSlug, courseSlug, file)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء رفع الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function updateCourseMediaAction(
  orgSlug: string,
  courseSlug: string,
  mediaId: number,
  data: { name?: string; file?: File }
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byId
    .patch(orgSlug, courseSlug, mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function getCourseMediaByIdAction(
  orgSlug: string,
  courseSlug: string,
  mediaId: number
): Promise<CourseMediaResponse | null> {
  return api.dashboard.media.byId
    .get(orgSlug, courseSlug, mediaId)
    .catch(() => null)
}

export async function deleteCourseMediaAction(
  orgSlug: string,
  courseSlug: string,
  mediaId: number
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.media.byId
    .delete(orgSlug, courseSlug, mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return {}
}
