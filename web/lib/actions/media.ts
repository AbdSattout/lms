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
  organizationId: number,
  orgSlug: string,
  page: number,
  size: number
): Promise<Page<PostMediaResponse>> {
  return api.dashboard.postMedia.byOrg.get(organizationId, { page, size })
}

export async function uploadPostMediaAction(
  organizationId: number,
  orgSlug: string,
  file: File
): Promise<{ error?: string; media?: PostMediaResponse }> {
  const media = await api.dashboard.postMedia.byOrg
    .post(organizationId, file)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء رفع الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return { media }
}

export async function updatePostMediaAction(
  organizationId: number,
  orgSlug: string,
  mediaId: number,
  data: { name?: string; file?: File }
): Promise<{ error?: string; media?: PostMediaResponse }> {
  const media = await api.dashboard.postMedia.byId
    .patch(organizationId, mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return { media }
}

export async function getPostMediaByIdAction(
  organizationId: number,
  mediaId: number
): Promise<PostMediaResponse | null> {
  return api.dashboard.postMedia.byId.get(organizationId, mediaId).catch(() => null)
}

export async function deletePostMediaAction(
  organizationId: number,
  orgSlug: string,
  mediaId: number
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.postMedia.byId
    .delete(organizationId, mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${orgSlug}/media`)
  return {}
}

/* ───── Course media ───── */

export async function fetchCourseMediaAction(
  organizationId: number,
  courseId: number,
  orgSlug: string,
  courseSlug: string,
  page: number,
  size: number
): Promise<PageCourseMediaResponse> {
  return api.dashboard.media.byCourse.get(organizationId, courseId, { page, size })
}

export async function uploadCourseMediaAction(
  organizationId: number,
  courseId: number,
  orgSlug: string,
  courseSlug: string,
  file: File
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byCourse
    .post(organizationId, courseId, file)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء رفع الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function updateCourseMediaAction(
  organizationId: number,
  courseId: number,
  orgSlug: string,
  courseSlug: string,
  mediaId: number,
  data: { name?: string; file?: File }
): Promise<{ error?: string; media?: CourseMediaResponse }> {
  const media = await api.dashboard.media.byId
    .patch(organizationId, courseId, mediaId, data.file, data.name)
    .catch(() => null)

  if (!media) return { error: "حدث خطأ أثناء تحديث الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return { media }
}

export async function getCourseMediaByIdAction(
  organizationId: number,
  courseId: number,
  mediaId: number
): Promise<CourseMediaResponse | null> {
  return api.dashboard.media.byId
    .get(organizationId, courseId, mediaId)
    .catch(() => null)
}

export async function deleteCourseMediaAction(
  organizationId: number,
  courseId: number,
  orgSlug: string,
  courseSlug: string,
  mediaId: number
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.media.byId
    .delete(organizationId, courseId, mediaId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الملف" }
  revalidatePath(`/${orgSlug}/courses/${courseSlug}/media`)
  return {}
}
