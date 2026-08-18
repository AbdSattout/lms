import { Badge } from "@/components/ui/badge"
import type { ReportStatus } from "@/lib/api/types"
import { cn } from "@/lib/utils"

const statusConfig: Record<
  ReportStatus,
  {
    label: string
    className: string
  }
> = {
  PENDING: {
    label: "قيد الانتظار",
    className:
      "border-amber-200 bg-amber-50 text-amber-700 dark:border-amber-900 dark:bg-amber-950/40 dark:text-amber-300",
  },
  UNDER_REVIEW: {
    label: "قيد المراجعة",
    className:
      "border-blue-200 bg-blue-50 text-blue-700 dark:border-blue-900 dark:bg-blue-950/40 dark:text-blue-300",
  },
  RESOLVED: {
    label: "تم الحل",
    className:
      "border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-900 dark:bg-emerald-950/40 dark:text-emerald-300",
  },
  REJECTED: {
    label: "مرفوض",
    className:
      "border-zinc-200 bg-zinc-50 text-zinc-600 dark:border-zinc-800 dark:bg-zinc-900/40 dark:text-zinc-400",
  },
}

export function ReportStatusBadge({
  status,
  className,
}: {
  status: ReportStatus
  className?: string
}) {
  const config = statusConfig[status]

  return (
    <Badge
      variant="outline"
      className={cn(
        "rounded-full px-2.5 py-0.5 text-[11px] font-bold",
        config.className,
        className
      )}
    >
      {config.label}
    </Badge>
  )
}
