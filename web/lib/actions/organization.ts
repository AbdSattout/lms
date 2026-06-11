"use server"

import { api } from "@/lib/api"
import { createOrganizationSchema, slugSchema } from "@/lib/validation"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"

export async function createOrganization(
  _prevState: { error?: string },
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

  const org = await api.organizations.list
    .post({ name, slug, description, visibility }, imageFile)
    .catch(() => null)

  if (!org) return { error: "حدث خطأ أثناء إنشاء المنظمة." }

  revalidatePath("/")
  redirect(`/${slug}`)
}

export async function checkSlugAvailability(slug: string) {
  if (!slug || !slugSchema.safeParse(slug).success) {
    return false
  }
  return api.organizations.checkSlugAvailability(slug)
}
