import type {
  CourseMediaResponse,
  PostMediaResponse,
} from "@/lib/api/types"

type MediaResult<T> = { error?: string; media?: T }

const backendBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL

let cachedToken: string | null = null

async function getBackendToken(): Promise<string | null> {
  if (cachedToken) return cachedToken

  try {
    const response = await fetch("/api/auth/token", {
      cache: "no-store",
    })

    if (!response.ok) return null

    const data = (await response.json()) as { token?: string }
    cachedToken = data.token ?? null
    return cachedToken
  } catch {
    return null
  }
}

function extractErrorMessage(data: unknown): string | null {
  if (!data) return null
  if (typeof data === "string" && data) return data

  if (typeof data === "object") {
    const { message, error } = data as { message?: unknown; error?: unknown }
    if (typeof message === "string" && message) return message
    if (typeof error === "string" && error) return error
  }

  return null
}

async function uploadToBackend<T>(
  backendPath: string,
  method: "POST" | "PATCH",
  file: File
): Promise<MediaResult<T>> {
  if (!backendBaseUrl) return { error: "حدث خطأ أثناء رفع الملف" }

  const token = await getBackendToken()
  if (!token) return { error: "انتهت الجلسة، يرجى تسجيل الدخول" }

  const formData = new FormData()
  formData.set("file", file)

  const url = new URL(
    backendPath.startsWith("/") ? backendPath : `/${backendPath}`,
    backendBaseUrl
  ).toString()

  try {
    const response = await fetch(url, {
      method,
      body: formData,
      headers: { Authorization: `Bearer ${token}` },
    })

    if (response.status === 401) {
      cachedToken = null
      return { error: "انتهت الجلسة، يرجى تسجيل الدخول" }
    }

    const data = await response.json().catch(() => null)

    if (!response.ok) {
      return { error: extractErrorMessage(data) ?? "حدث خطأ أثناء رفع الملف" }
    }

    return { media: data as T }
  } catch {
    return { error: "حدث خطأ أثناء رفع الملف" }
  }
}

export function uploadCourseMedia(
  organizationId: number,
  courseId: number,
  file: File
) {
  return uploadToBackend<CourseMediaResponse>(
    `dashboard/organizations/${organizationId}/courses/${courseId}/media`,
    "POST",
    file
  )
}

export function replaceCourseMediaFile(
  organizationId: number,
  courseId: number,
  mediaId: number,
  file: File
) {
  return uploadToBackend<CourseMediaResponse>(
    `dashboard/organizations/${organizationId}/courses/${courseId}/media/${mediaId}`,
    "PATCH",
    file
  )
}

export function uploadPostMedia(organizationId: number, file: File) {
  return uploadToBackend<PostMediaResponse>(
    `dashboard/organizations/${organizationId}/post-media`,
    "POST",
    file
  )
}

export function replacePostMediaFile(
  organizationId: number,
  mediaId: number,
  file: File
) {
  return uploadToBackend<PostMediaResponse>(
    `dashboard/organizations/${organizationId}/post-media/${mediaId}`,
    "PATCH",
    file
  )
}
