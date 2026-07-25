"use server"

import { api } from "@/lib/api"
import { CreateInviteRequest, CreatePublicInviteRequest } from "../api/types"

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
  return await api.dashboard.organizations.invites.create.post(slug, request)
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
