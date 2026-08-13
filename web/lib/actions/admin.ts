"use server"

import { revalidatePath } from "next/cache"
import { banUser, unbanUser } from "../api/organizations"

export async function submitUserBan(userId: number, formData: FormData) {
  const reason = formData.get("reason") as string

  try {
    await banUser.post(userId, { reason })
    revalidatePath("/admin/bans")
    return { success: true }
  } catch (error) {
    console.error("فشل الحظر:", error)
    return { error: "Failed to ban user." }
  }
}

export async function submitUserUnban(userId: number) {
  try {
    await unbanUser.delete(userId)
    revalidatePath("/admin/bans")
    return { success: true }
  } catch {
    return { error: "Failed to unban user." }
  }
}
