import { BadgeCheck } from "lucide-react"

import { cn } from "@/lib/utils"

export function OrganizationVerifiedBadge({
  className,
  showLabel = false,
}: {
  className?: string
  showLabel?: boolean
}) {
  return (
    <span
      title="منظمة موثقة"
      aria-label="منظمة موثقة"
      className={cn(
        "inline-flex shrink-0 items-center gap-1 rounded-full text-sky-600 dark:text-sky-400",
        showLabel && "bg-sky-500/10 px-2 py-0.5 text-xs font-semibold",
        className
      )}
    >
      <BadgeCheck className="h-4 w-4 fill-sky-100 dark:fill-sky-950" />
      {showLabel && <span>موثقة</span>}
    </span>
  )
}
