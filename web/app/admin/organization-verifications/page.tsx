import { getOrganizationVerificationsAction } from "@/lib/actions/admin"
import { OrganizationVerificationsPage } from "./verification-page"

export default async function AdminOrganizationVerificationsPage() {
  const requests = await getOrganizationVerificationsAction("PENDING", {
    page: 0,
    size: 50,
    sort: ["createdAt,desc"],
  })

  return (
    <OrganizationVerificationsPage
      initialRequests={requests.content ?? []}
      totalElements={requests.totalElements ?? 0}
    />
  )
}
