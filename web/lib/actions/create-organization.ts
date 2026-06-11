"use server"

import { api } from "@/lib/api"
import type { CreateOrganizationRequest } from "@/lib/api/types"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"

export async function createOrganization(
  prevState: { error?: string },
  formData: FormData
) {
  const name = formData.get("name") as string
  const description = formData.get("description") as string
  const visibility = formData.get("visibility") as "PUBLIC" | "PRIVATE"
  const image = formData.get("image") as File | null
  const slug = formData.get("slug") as string

  if (!name || !description || !visibility) {
    return { error: "يرجى تعبئة جميع الحقول المطلوبة." }
  }

  if (!slug || !/^[a-z0-9-]+$/.test(slug)) {
    return { error: "الرابط يجب أن يحتوي على أحرف إنجليزية صغيرة وشرطات فقط." }
  }

  const request: CreateOrganizationRequest = {
    name,
    slug,
    description,
    visibility,
  }

  const imageFile = image && image.size > 0 ? image : undefined
  const org = await api.organizations.list
    .post(request, imageFile)
    .catch(() => null)

  if (!org) return { error: "حدث خطأ أثناء إنشاء المنظمة." }

  revalidatePath("/")
  redirect(`/${slug}`)
}
