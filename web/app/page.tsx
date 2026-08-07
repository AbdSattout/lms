import { Suspense } from "react"
import { OrgsGrid } from "@/components/orgs-grid"
import { OrgsGridSkeleton } from "@/components/skeletons/orgs-grid-skeleton"
import { Notifications } from "@/components/ui/notification_button"
import { SubscriptionButton } from "@/components/ui/subscription-button"

export default function HomePage() {
  return (
    <div className="container mx-auto flex flex-col gap-6 p-4">
      <div className="flex items-center justify-between">
        <h1 className="font-heading text-2xl font-bold">منظماتي</h1>
        <div className="flex items-center gap-3">
          <SubscriptionButton />
          <Notifications />
        </div>
      </div>

      <Suspense fallback={<OrgsGridSkeleton />}>
        <OrgsGrid />
      </Suspense>
    </div>
  )
}
