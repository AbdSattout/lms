// lib/actions/invites.ts
"use server"

import { api } from "@/lib/api"
import { OrganizationInviteResponse } from "../api/types"
import { revalidatePath } from "next/cache"

export async function getMyPendingInvitesAction(): Promise<
  OrganizationInviteResponse[]
> {
  try {
    const invites = await api.dashboard.organizations.invites.getMyInvites.get()
    console.log("Fetched invites:", invites)
    return invites.filter((invite) => invite.status === "PENDING")
  } catch (error) {
    console.error("Failed to fetch invites:", error)
    return []
  }
}

export async function acceptInviteAction(token: string): Promise<{
  success: boolean
  error?: string
}> {
  try {
    await api.dashboard.organizations.invites.accept.post(token)
    revalidatePath("/")
    return { success: true }
  } catch (error) {
    console.error("Failed to accept invite:", error)
    return {
      success: false,
      error: error instanceof Error ? error.message : "Failed to accept invite",
    }
  }
}

export async function declineInviteAction(token: string): Promise<{
  success: boolean
  error?: string
}> {
  try {
    // Use the API endpoint you already defined
    await api.dashboard.organizations.invites.decline.post(token)
    revalidatePath("/")
    return { success: true }
  } catch (error) {
    console.error("Failed to decline invite:", error)
    return {
      success: false,
      error:
        error instanceof Error ? error.message : "Failed to decline invite",
    }
  }
}
