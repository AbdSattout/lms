"use server"

import { api } from "@/lib/api"
import type {
  ChapterResponse,
  LessonResponse,
  QuestionResponse,
} from "@/lib/api/types"
import {
  createCourseSchema,
  createQuestionSchema,
  updateCourseSchema,
  updateQuestionSchema,
} from "@/lib/validation"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"

type ActionState = { error?: string; success?: boolean; slug?: string }

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
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const { title, slug, description } = result.data
  const cover = formData.get("cover") as File | null
  const coverFile = cover?.size ? cover : undefined

  const course = await api.dashboard.organizations.courses
    .post(orgSlug, { title, slug, description }, coverFile)
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
  const oldSlug = formData.get("oldSlug") as string | null

  if (isNaN(courseId) || !orgSlug) return { error: "بيانات غير صالحة" }

  const result = updateCourseSchema.safeParse({
    title: formData.get("title") || undefined,
    slug: formData.get("slug") || undefined,
    description: formData.get("description") || undefined,
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const cover = formData.get("cover") as File | null
  const coverFile = cover?.size ? cover : undefined

  const updated = await api.dashboard.courses.byId
    .patch(courseId, result.data, coverFile)
    .catch(() => null)

  if (!updated) return { error: "حدث خطأ أثناء تحديث الدورة." }

  const newSlug = updated.slug
  revalidatePath(`/${orgSlug}/courses`)
  revalidatePath(`/${orgSlug}/courses/${newSlug}`)

  if (oldSlug && oldSlug !== newSlug) {
    redirect(`/${orgSlug}/courses/${newSlug}`)
  }

  return { success: true }
}

export async function publishCourse(
  courseId: number,
  orgSlug: string
): Promise<ActionState> {
  const published = await api.dashboard.courses.publish
    .post(courseId)
    .catch(() => null)

  if (published === null) return { error: "حدث خطأ أثناء نشر الدورة." }

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

  const deleted = await api.dashboard.courses.byId
    .delete(courseId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الدورة." }

  revalidatePath(`/${orgSlug}/courses`)
  return { success: true }
}

export async function createChapterAction(
  courseId: number,
  title: string,
  orgSlug: string
): Promise<{ error?: string; chapter?: ChapterResponse }> {
  const chapter = await api.dashboard.courses.chapters.create
    .post(courseId, { title })
    .catch(() => null)

  if (!chapter) return { error: "حدث خطأ أثناء إنشاء الفصل" }

  revalidatePath(`/${orgSlug}/courses`)
  return { chapter }
}

export async function updateChapterAction(
  chapterId: number,
  title: string,
  orgSlug: string
): Promise<{ error?: string; chapter?: ChapterResponse }> {
  const chapter = await api.dashboard.chapters.byId
    .patch(chapterId, { title })
    .catch(() => null)

  if (!chapter) return { error: "حدث خطأ أثناء تحديث الفصل" }

  revalidatePath(`/${orgSlug}/courses`)
  return { chapter }
}

export async function deleteChapterAction(
  chapterId: number,
  orgSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.chapters.byId
    .delete(chapterId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الفصل" }

  revalidatePath(`/${orgSlug}/courses`)
  return {}
}

export async function reorderChaptersAction(
  courseId: number,
  chapterIds: number[],
  orgSlug: string
): Promise<{ error?: string }> {
  const result = await api.dashboard.courses.chapters.reorder
    .patch(courseId, { chapterIds })
    .catch(() => null)

  if (result === null) return { error: "حدث خطأ أثناء ترتيب الفصول" }

  revalidatePath(`/${orgSlug}/courses`)
  return {}
}

export async function createLessonAction(
  chapterId: number,
  title: string,
  orgSlug: string
): Promise<{ error?: string; lesson?: LessonResponse }> {
  const lesson = await api.dashboard.lessons.create
    .post(chapterId, { title })
    .catch(() => null)

  if (!lesson) return { error: "حدث خطأ أثناء إنشاء الدرس" }

  revalidatePath(`/${orgSlug}/courses`)
  return { lesson }
}

export async function updateLessonAction(
  lessonId: number,
  data: { title?: string; chapterId?: number },
  orgSlug: string
): Promise<{ error?: string; lesson?: LessonResponse }> {
  const lesson = await api.dashboard.lessons.byId
    .patch(lessonId, data)
    .catch(() => null)

  if (!lesson) return { error: "حدث خطأ أثناء تحديث الدرس" }

  revalidatePath(`/${orgSlug}/courses`)
  return { lesson }
}

export async function deleteLessonAction(
  lessonId: number,
  orgSlug: string
): Promise<{ error?: string }> {
  const deleted = await api.dashboard.lessons.byId
    .delete(lessonId)
    .catch(() => null)

  if (deleted === null) return { error: "حدث خطأ أثناء حذف الدرس" }

  revalidatePath(`/${orgSlug}/courses`)
  return {}
}

export async function reorderLessonsAction(
  chapterId: number,
  lessonIds: number[],
  orgSlug: string
): Promise<{ error?: string }> {
  const result = await api.dashboard.lessons.reorder
    .patch(chapterId, { lessonIds })
    .catch(() => null)

  if (result === null) return { error: "حدث خطأ أثناء ترتيب الدروس" }

  revalidatePath(`/${orgSlug}/courses`)
  return {}
}

export async function createQuestionAction(
  courseId: number,
  data: { content: string; options: string[]; correctAnswerIndex: number },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; question?: QuestionResponse }> {
  const parsed = createQuestionSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const question = await api.dashboard.questions.create
    .post(courseId, parsed.data)
    .catch(() => null)

  if (!question) return { error: "حدث خطأ أثناء إنشاء السؤال" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/questions`)
  return { question }
}

export async function updateQuestionAction(
  questionId: number,
  data: {
    content?: string
    options?: string[]
    correctAnswerIndex?: number
    difficulty?: "EASY" | "MEDIUM" | "HARD"
  },
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; question?: QuestionResponse }> {
  const parsed = updateQuestionSchema.safeParse(data)
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "بيانات غير صالحة" }
  }

  const question = await api.dashboard.questions.byId
    .patch(questionId, parsed.data)
    .catch(() => null)

  if (!question) return { error: "حدث خطأ أثناء تحديث السؤال" }

  revalidatePath(`/${orgSlug}/courses/${courseSlug}/questions`)
  return { question }
}

export async function deleteQuestionAction(
  questionId: number,
  orgSlug: string,
  courseSlug: string
): Promise<{ error?: string; conflict?: boolean }> {
  try {
    await api.dashboard.questions.byId.delete(questionId)
    revalidatePath(`/${orgSlug}/courses/${courseSlug}/questions`)
    return {}
  } catch (error) {
    if (error instanceof Error && error.message.includes("(409)")) {
      return {
        error:
          "لا يمكن حذف السؤال لأنه مستخدم في درس أو اختبار. قم بإزالته من هناك أولاً.",
        conflict: true,
      }
    }
    return { error: "حدث خطأ أثناء حذف السؤال" }
  }
}
