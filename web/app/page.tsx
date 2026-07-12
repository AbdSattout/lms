import { Suspense } from "react"

import { OrgsGrid } from "@/components/orgs-grid"
import { OrgsGridSkeleton } from "@/components/skeletons/orgs-grid-skeleton"

export default function HomePage() {
  return (
    <div className="p-8">
      <h1 className="mb-6 font-heading text-2xl">منظماتي</h1>

      <Suspense fallback={<OrgsGridSkeleton />}>
        <OrgsGrid />
      </Suspense>
    </div>
  )
}
