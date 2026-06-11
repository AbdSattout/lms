"use server"

import { api } from "@/lib/api"
import { createCourseSchema, updateCourseSchema } from "@/lib/validation"
import { revalidatePath } from "next/cache"

type ActionState = { error?: string; success?: boolean }

export async function createCourse(
  _prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const orgSlug = formData.get("orgSlug") as string
  if (!orgSlug) return { error: "معرف المنظمة مطلوب" }

  const result = createCourseSchema.safeParse({
    title: formData.get("title"),
    slug: formData.get("slug"),
    description: formData.get("description") || undefined,
    coverUrl: formData.get("coverUrl") || undefined,
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const { title, slug, description, coverUrl } = result.data
  const cover = formData.get("cover") as File | null
  const coverFile = cover?.size ? cover : undefined

  const course = await api.organizations.courses
    .post(orgSlug, { title, slug, description, coverUrl }, coverFile)
    .catch(() => null)

  if (!course) return { error: "حدث خطأ أثناء إنشاء الدورة." }

  revalidatePath(`/${orgSlug}/courses`)
  return { success: true }
}

export async function updateCourse(
  _prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const courseId = Number(formData.get("courseId"))
  const orgSlug = formData.get("orgSlug") as string

  if (isNaN(courseId) || !orgSlug) return { error: "بيانات غير صالحة" }

  const result = updateCourseSchema.safeParse({
    title: formData.get("title") || undefined,
    slug: formData.get("slug") || undefined,
    description: formData.get("description") || undefined,
    coverUrl: formData.get("coverUrl") || undefined,
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const cover = formData.get("cover") as File | null
  const coverFile = cover?.size ? cover : undefined

  const updated = await api.courses.byId
    .patch(courseId, result.data, coverFile)
    .catch(() => null)

  if (!updated) return { error: "حدث خطأ أثناء تحديث الدورة." }

  revalidatePath(`/${orgSlug}/courses`)
  return { success: true }
}

export async function deleteCourseCover(courseId: number, orgSlug: string) {
  const updated = await api.courses.byId
    .patch(courseId, { coverUrl: "" })
    .catch(() => null)

  if (updated === null) return { error: "حدث خطأ أثناء حذف الغلاف." }

  revalidatePath(`/${orgSlug}/courses`)
  return { success: true }
}

export async function deleteCourse(
  _prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const courseId = Number(formData.get("courseId"))
  const orgSlug = formData.get("orgSlug") as string

  if (isNaN(courseId) || !orgSlug) return { error: "بيانات غير صالحة" }

  const deleted = await api.courses.byId.delete(courseId).catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الدورة." }

  revalidatePath(`/${orgSlug}/courses`)
  return { success: true }
}
