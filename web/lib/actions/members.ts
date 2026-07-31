// lib/actions/members.ts
"use server"

import { api } from "@/lib/api"
import {
  CreateInviteRequest,
  CreatePublicInviteRequest,
  UpdateInviteCapacityRequest,
} from "@/lib/api/types"

export async function getMembers(
  slug: string,
  type: "admins" | "students",
  pageable: { page: number; size: number }
) {
  if (type === "admins") {
    return await api.dashboard.organizations.members.getAdmins(slug, pageable)
  }
  return await api.dashboard.organizations.members.getStudents(slug, pageable)
}

export async function searchUsers(query: string) {
  if (!query || query.length < 2) return []
  return await api.users.search(query)
}

export async function createInvite(slug: string, request: CreateInviteRequest) {
  try {
    const data = await api.dashboard.organizations.invites.create.post(
      slug,
      request
    )
    return { success: true, data, error: null }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error)
    return { success: false, data: null, error: errorMessage }
  }
}

export async function createPublicInvite(
  slug: string,
  request: CreatePublicInviteRequest
) {
  return await api.dashboard.organizations.invites.createPublic.post(
    slug,
    request
  )
}

export async function getPendingInvites(slug: string) {
  return await api.dashboard.organizations.invites.list.get(slug)
}

export async function cancelInvite(slug: string, inviteId: number) {
  return await api.dashboard.organizations.invites.cancel.post(slug, inviteId)
}

export async function updateInviteCapacity(
  slug: string,
  inviteId: number,
  request: UpdateInviteCapacityRequest
) {
  return await api.dashboard.organizations.invites.updateCapacity.patch(
    slug,
    inviteId,
    request
  )
}

export async function resendInvite(slug: string, inviteId: number) {
  return await api.dashboard.organizations.invites.resend.post(slug, inviteId)
}
