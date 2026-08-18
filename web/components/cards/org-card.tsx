import { OrgAvatar } from "@/components/org-avatar"
import { OrganizationVerifiedBadge } from "@/components/organization-verified-badge"
import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { OrganizationResponse } from "@/lib/api/types"
import Link from "next/link"

export async function OrgCard({ org }: { org: OrganizationResponse }) {
  return (
    <Link href={`/${org.slug}`}>
      <Card className="h-full cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-xl">
        <CardHeader className="relative flex-row items-center gap-3 space-y-0">
          <Badge variant="secondary" className="absolute inset-e-6 top-0">
            {org.visibility === "PUBLIC" ? "عام" : "خاص"}
          </Badge>
          <OrgAvatar src={org.image} name={org.name} />
          <div className="min-w-0 flex-1">
            <div className="flex items-center justify-between gap-2">
              <CardTitle className="truncate text-base">{org.name}</CardTitle>
              {org.verified && <OrganizationVerifiedBadge />}
            </div>
            {org.description && (
              <CardDescription className="line-clamp-2 text-xs">
                {org.description}
              </CardDescription>
            )}
          </div>
        </CardHeader>
        <CardFooter className="mt-auto text-xs text-muted-foreground">
          {org.ownerName}
        </CardFooter>
      </Card>
    </Link>
  )
}
