"use server"

import { api } from "@/lib/api"
import type { User } from "@/lib/api/types"
import { getImageUploadError } from "@/lib/utils/image-upload"
import { revalidatePath } from "next/cache"

export async function updateProfilePictureAction(
  image: File
): Promise<{ error?: string; user?: User }> {
  const error = getImageUploadError(image)
  if (error) return { error }

  const user = await api.users.picture.patch(image).catch(() => null)

  if (!user) return { error: "حدث خطأ أثناء تحديث الصورة الشخصية" }

  revalidatePath("/")
  return { user }
}
