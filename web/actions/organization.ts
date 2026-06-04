"use server"

import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"
import { api } from "@/lib/api"
import type { CreateOrganizationRequest } from "@/lib/api/types"
export async function createOrganization(
  prevState: {
    error?: string
  },
  formData: FormData
) {
  const name = formData.get("name") as string
  const description = formData.get("description") as string
  const visibility = formData.get("visibility") as "PUBLIC" | "PRIVATE"
  const image = formData.get("image") as File | null

  if (!name || !description || !visibility) {
    return { error: "يرجى تعبئة جميع الحقول المطلوبة." }
  }

  const slug = name
    .trim()
    .toLowerCase()
    .replace(/[\s_]+/g, "-")

  const request: CreateOrganizationRequest = {
    name,
    slug,
    description,
    visibility,
  }

  try {
    const imageFile = image && image.size > 0 ? image : undefined
    await api.organizations.list.post(request, imageFile)
  } catch (error) {
    console.error(error)
    return { error: "حدث خطأ أثناء إنشاء المنظمة." }
  }

  revalidatePath("/organization")
  redirect("/dashboard")
}
