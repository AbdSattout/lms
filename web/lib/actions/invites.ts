"use server"

import { api } from "@/lib/api"
import { OrganizationInviteResponse } from "../api/types"

export async function getMyPendingInvitesAction(): Promise<
  OrganizationInviteResponse[]
> {
  try {
    const invites = await api.dashboard.organizations.invites.getMyInvites.get()
    console.log("Fetched invites:", invites)
    return invites
  } catch (error) {
    console.error("Failed to fetch invites:", error)
    return []
  }
}
