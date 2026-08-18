"use client"

import useSWR from "swr"

import type { OrganizationOverviewResponse } from "@/lib/api/types"
import { getOrganizationOverviewAction } from "@/lib/actions/organization"

export function useOrganizationOverview(
  slug: string,
  initialData?: OrganizationOverviewResponse
) {
  return useSWR<OrganizationOverviewResponse>(
    ["organization-overview", slug],
    () => getOrganizationOverviewAction(slug),
    {
      fallbackData: initialData,
      refreshInterval: 5000,
      revalidateOnFocus: true,
      revalidateOnReconnect: true,
    }
  )
}
