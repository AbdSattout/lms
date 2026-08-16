"use server"

import { api } from "@/lib/api"
import type { JoinRequestResponse } from "@/lib/api/types"

export async function getPendingJoinRequestsAction(
  slug: string
): Promise<JoinRequestResponse[]> {
  try {
    return await api.dashboard.organizations.joinRequests.listPending(slug)
  } catch (error) {
    console.error("Failed to fetch pending join requests:", error)
    return []
  }
}

export async function acceptJoinRequestAction(
  slug: string,
  id: number
): Promise<{ success: boolean; error?: string }> {
  try {
    await api.dashboard.organizations.joinRequests.accept.post(slug, id)

    return { success: true }
  } catch (error) {
    console.error("Failed to accept join request:", error)

    return {
      success: false,
      error: error instanceof Error ? error.message : "فشل قبول طلب الانضمام",
    }
  }
}

export async function rejectJoinRequestAction(
  slug: string,
  id: number
): Promise<{ success: boolean; error?: string }> {
  try {
    await api.dashboard.organizations.joinRequests.reject.post(slug, id)

    return { success: true }
  } catch (error) {
    console.error("Failed to reject join request:", error)

    return {
      success: false,
      error: error instanceof Error ? error.message : "فشل رفض طلب الانضمام",
    }
  }
}
