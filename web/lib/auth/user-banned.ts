import { BackendError } from "@/lib/api/backend"

export const USER_BANNED_ERROR_CODE = "USER_BANNED"

export const USER_BANNED_MESSAGE =
  "تم حظر حسابك، لا يمكنك تسجيل الدخول. تواصل مع الدعم إذا كنت تعتقد أن هذا خطأ."

export function isUserBannedError(error: unknown): boolean {
  return (
    error instanceof BackendError &&
    (error.code === USER_BANNED_ERROR_CODE ||
      error.message.includes("User is banned"))
  )
}