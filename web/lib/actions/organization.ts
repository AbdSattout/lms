"use server"

import { api } from "@/lib/api"
import { createOrganizationSchema, slugSchema } from "@/lib/validation"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"
import type { UpdateOrganizationRequest } from "@/lib/api/types"
export async function createOrganization(
  _prevState: { error?: string; success?: boolean; slug?: string },
  formData: FormData
) {
  const result = createOrganizationSchema.safeParse({
    name: formData.get("name"),
    slug: formData.get("slug"),
    description: formData.get("description"),
    visibility: formData.get("visibility"),
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const { name, slug, description, visibility } = result.data
  const image = formData.get("image") as File | null
  const imageFile = image && image.size > 0 ? image : undefined

  const org = await api.dashboard.organizations.create
    .post({ name, slug, description, visibility }, imageFile)
    .catch(() => null)

  if (!org) return { error: "حدث خطأ أثناء إنشاء المنظمة." }

  revalidatePath("/")
  return { success: true, slug }
}

export async function checkSlugAvailability(slug: string) {
  if (!slug || !slugSchema.safeParse(slug).success) {
    return false
  }
  return api.dashboard.organizations.checkSlugAvailability(slug)
}
export async function deleteOrganizationAction(slug: string) {
  try {
    await api.dashboard.organizations.bySlug.delete(slug)

    revalidatePath("/")
  } catch (error) {
    console.error("Delete failed:", error)
    return { success: false, error: "Failed to delete" }
  }
  redirect("/")
}

export async function updateOrganizationAction(formData: FormData) {
  const oldSlug = formData.get("oldSlug") as string
  const name = formData.get("name") as string
  const description = formData.get("description") as string
  const image = formData.get("image") as File | null

  if (!oldSlug || !name) {
    return { success: false, error: "اسم المؤسسة مطلوب (Name is required)" }
  }

  const newSlug = name
    .toLowerCase()
    .trim()
    .replace(/[\s\W-]+/g, "-") // Replaces spaces and special chars with hyphens

  // 3. Put the new slug inside the request body for your backend to save
  const request: UpdateOrganizationRequest = {
    name,
    description: description || undefined,
    slug: newSlug,
  }
  let isSuccess = false
  try {
    await api.dashboard.organizations.bySlug.patch(
      oldSlug,
      request,
      image || undefined
    )

    revalidatePath(`/${oldSlug}`)
    revalidatePath(`/${newSlug}`)
    isSuccess = true
  } catch (error) {
    console.error("Failed to update organization:", error)
    return { success: false, error: "حدث خطأ أثناء الحفظ (Error saving)" }
  }
  if (isSuccess && oldSlug !== newSlug) {
    redirect(`/${newSlug}/settings`)
  }
  return { success: true, newSlug }
}
