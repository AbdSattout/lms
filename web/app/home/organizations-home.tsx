import { Suspense } from "react"
import { LogOut } from "lucide-react"
import { OrgsGrid } from "@/components/orgs-grid"
import { OrgsGridSkeleton } from "@/components/skeletons/orgs-grid-skeleton"
import { Notifications } from "@/components/ui/invite-notification_button"
import { SubscriptionButton } from "@/components/ui/subscription-button"
import { LogoutButton } from "@/components/auth/logout-button"

export default function OrganizationsHome() {
  return (
    <div className="container mx-auto flex flex-col gap-6 p-4">
      <div className="flex items-center justify-between">
        <h1 className="font-heading text-2xl font-bold">منظماتي</h1>
        <div className="flex items-center gap-3">
          <SubscriptionButton />
          <Notifications />
          <LogoutButton
            variant="ghost"
            size="icon"
            className="h-12 w-12 rounded-full text-muted-foreground transition-colors hover:bg-muted/50 hover:text-foreground"
          >
            <LogOut className="h-10 w-10 rtl:rotate-180" strokeWidth={3.5} />
          </LogoutButton>
        </div>
      </div>

      <Suspense fallback={<OrgsGridSkeleton />}>
        <OrgsGrid />
      </Suspense>
    </div>
  )
}
