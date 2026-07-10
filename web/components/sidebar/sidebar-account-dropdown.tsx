import { api } from "@/lib/api"
import type { OrganizationResponse } from "@/lib/api/types"
import { notFound } from "next/navigation"

import { SidebarAccountDropdownMenu } from "./sidebar-account-dropdown-menu"

export async function SidebarAccountDropdown({
  orgPromise,
}: {
  orgPromise: Promise<OrganizationResponse>
}) {
  const [org, user, organizations] = await Promise.all([
    orgPromise.catch(() => notFound()),
    api.users.me(),
    api.organizations.list().catch(() => []),
  ])

  return (
    <SidebarAccountDropdownMenu
      org={org}
      user={user}
      organizations={organizations.filter((o) => o.slug !== org.slug)}
    />
  )
}
