"use server"

import { moderators } from "@/lib/api/admin"
import type { CreateModeratorRequest } from "@/lib/api/types"
import type { PageableInput } from "@/lib/validation"

export async function getAdminModeratorsAction(pageable: PageableInput) {
  return moderators.list.get(pageable)
}

export async function createAdminModeratorAction(
  request: CreateModeratorRequest
) {
  return moderators.create.post(request)
}

export async function deleteAdminModeratorAction(moderatorId: number) {
  return moderators.remove.delete(moderatorId)
}
