"use client"

import useSWR from "swr"

import type { JoinRequestResponse } from "@/lib/api/types"
import { getPendingJoinRequestsAction } from "@/lib/actions/join-request"

export function usePendingJoinRequests(slug: string) {
  return useSWR<JoinRequestResponse[]>(
    ["org-join-requests", slug],
    () => getPendingJoinRequestsAction(slug),
    {
      refreshInterval: 10000,
      revalidateOnFocus: true,
      revalidateOnReconnect: true,
    }
  )
}
