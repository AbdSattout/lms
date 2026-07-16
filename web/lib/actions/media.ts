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
  mediaId: number,
  data: { name?: string; file?: File },
  orgSlug: string
): Promise<{ error?: string; media?: PostMediaResponse }> {
  const media = await api.dashboard.postMedia.byId
    .patch(mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return { media }
}

export async function deletePostMediaAction(
  mediaId: number,
  orgSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.postMedia.byId
    .delete(mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return {}
}

/* ───── Course media ───── */

export async function fetchCourseMediaAction(
  courseId: number,
  page: number,
  size: number
): Promise<PageCourseMediaResponse> {
  return api.dashboard.media.byCourse.get(courseId, { page, size })
}

export async function uploadCourseMediaAction(
  courseId: number,
  file: File,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byCourse
    .post(courseId, file)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء رفع الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function updateCourseMediaAction(
  courseId: number,
  mediaId: number,
  data: { name?: string; file?: File },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byId
    .patch(courseId, mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function deleteCourseMediaAction(
  courseId: number,
  mediaId: number,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.media.byId
    .delete(courseId, mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return {}
}
