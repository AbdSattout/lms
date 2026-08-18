"use client"

import useSWR from "swr"
import type { OrganizationInviteResponse } from "@/lib/api/types"
import { getMyPendingInvitesAction } from "@/lib/actions/invites"

export function usePendingInvites() {
  return useSWR<OrganizationInviteResponse[]>(
    "my-pending-invites",
    getMyPendingInvitesAction,
    {
      refreshInterval: 10000,
      revalidateOnFocus: true,
      revalidateOnReconnect: true,
    }
  )
}
