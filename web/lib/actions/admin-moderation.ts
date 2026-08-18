"use server"

import { moderation } from "@/lib/api/admin"
import { PageableInput } from "../validation"
import { BanRequest } from "../api/types"

export async function getAdminUsersAction(
  q: string | undefined,
  pageable: PageableInput
) {
  return moderation.users.list.get(q, pageable)
}

export async function getAdminOrganizationsAction(
  q: string | undefined,
  pageable: PageableInput
) {
  return moderation.organizations.list.get(q, pageable)
}

export async function getBannedUsersAction(pageable: PageableInput) {
  return moderation.users.banned.get(pageable)
}

export async function getBannedOrganizationsAction(pageable: PageableInput) {
  return moderation.organizations.banned.get(pageable)
}

export async function banUserAction(userId: number, request: BanRequest) {
  return moderation.users.ban.post(userId, request)
}

export async function unbanUserAction(userId: number) {
  return moderation.users.unban.delete(userId)
}

export async function banOrganizationAction(
  organizationId: number,
  request: BanRequest
) {
  return moderation.organizations.ban.post(organizationId, request)
}

export async function unbanOrganizationAction(organizationId: number) {
  return moderation.organizations.unban.delete(organizationId)
}
