"use server"

import { api } from "@/lib/api"
import { getImageUploadError } from "@/lib/utils/image-upload"
import {
  createOrganizationSchema,
  slugSchema,
  updateOrganizationSchema,
} from "@/lib/validation"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"
import type { OrganizationOverviewResponse } from "../api/types"
import type { PageableInput } from "../validation"
import { BackendError, SubscriptionLimitError } from "../api/backend"

type OrganizationVerificationFormState = {
  error?: string
  success?: boolean
}

export async function getOrganizationOverviewAction(
  slug: string
): Promise<OrganizationOverviewResponse> {
  return api.dashboard.organizations.overview.get(slug)
}

export async function getOrganizationVerificationRequestsAction(
  slug: string,
  pageable: PageableInput
) {
  return api.dashboard.organizations.verificationRequests.list.get(
    slug,
    pageable
  )
}

export async function submitOrganizationVerificationAction(
  _prevState: OrganizationVerificationFormState,
  formData: FormData
): Promise<OrganizationVerificationFormState> {
  const slug = String(formData.get("slug") ?? "")
  const note = String(formData.get("note") ?? "").trim()
  const proof = formData.get("proof")

  if (!slug) {
    return { error: "معرف المنظمة مطلوب." }
  }

  if (!(proof instanceof File) || proof.size === 0) {
    return { error: "ملف الإثبات مطلوب." }
  }

  try {
    await api.dashboard.organizations.verificationRequests.submit.post(
      slug,
      note ? { note } : {},
      proof
    )
  } catch (error) {
    console.error("Submit organization verification failed:", error)
    return {
      error: error instanceof Error ? error.message : "تعذر إرسال طلب التوثيق.",
    }
  }

  revalidatePath(`/${slug}/settings`)

  return { success: true }
}

export async function createOrganization(
  _prevState: { error?: string; success?: boolean },
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
  const imageError = getImageUploadError(image)
  if (imageError) return { error: imageError }
  const imageFile = image && image.size > 0 ? image : undefined
  try {
    const org = await api.dashboard.organizations.create.post(
      { name, slug, description, visibility },
      imageFile
    )

    revalidatePath("/")
    redirect(`/${org.slug}`)
  } catch (error) {
    if (error instanceof SubscriptionLimitError) {
      return {
        error: error.message,
      }
    }

    console.error("Create organization failed:", error)

    return {
      error: "حدث خطأ أثناء إنشاء المنظمة.",
    }
  }
}
export async function leaveOrganizationAction(slug: string) {
  try {
    await api.dashboard.organizations.leave.post(slug)
    return { success: true }
  } catch {
    return { success: false, error: "فشل مغادرة المنظمة" }
  }
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

    return {
      success: true,
    }
  } catch (error) {
    console.error("Delete organization failed:", error)

    if (error instanceof Error) {
      console.error("Delete error:", error.message)
    }

    return {
      success: false,
      error:
        error instanceof BackendError
          ? error.message
          : "تعذر حذف المنظمة. قد تكون مرتبطة ببيانات موجودة.",
    }
  }
}
export async function updateOrganization(
  _prevState: { error?: string; success?: boolean },
  formData: FormData
) {
  const oldSlug = formData.get("oldSlug") as string
  const name = formData.get("name") as string
  const slug = formData.get("slug") as string
  const description = formData.get("description") as string
  const visibility = formData.get("visibility") as string | null
  const image = formData.get("image") as File | null

  if (!oldSlug) {
    return { error: "معرف المنظمة مطلوب" }
  }

  const result = updateOrganizationSchema.safeParse({
    name: name || undefined,
    slug: slug || undefined,
    description: description || undefined,
    visibility: visibility || undefined,
  })

  if (!result.success) {
    return {
      error: result.error.issues[0]?.message || "فشل التحقق من صحة البيانات",
    }
  }

  const request = result.data
  const imageError = getImageUploadError(image)
  if (imageError) return { error: imageError }
  const imageFile = image && image.size > 0 ? image : undefined

  try {
    await api.dashboard.organizations.bySlug.patch(oldSlug, request, imageFile)
  } catch (error) {
    console.error("Failed to update organization:", error)
    return { error: "حدث خطأ أثناء الحفظ" }
  }

  revalidatePath(`/${oldSlug}`)
  if (request.slug && oldSlug !== request.slug) {
    revalidatePath(`/${request.slug}`)
    redirect(`/${request.slug}/settings`)
  }
  revalidatePath(`/${oldSlug}/settings`)
  return { success: true }
}
