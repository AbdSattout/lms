import { OrgCard } from "@/components/cards/org-card"
import { CreateOrgTile } from "@/components/create-org-tile"
import { api } from "@/lib/api"

export async function OrgsGrid() {
  const organizations = await api.organizations.list()

  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4 *:aspect-video *:min-h-0 *:w-full">
      <CreateOrgTile />

      {organizations.map((org) => (
        <OrgCard key={org.slug} org={org} />
      ))}
    </div>
  )
}
