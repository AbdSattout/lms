"use client"

import { cn } from "@/lib/utils"
import type { ReportStatus } from "@/lib/api/types"

const filters: Array<{
  value: ReportStatus | "ALL"
  label: string
}> = [
  { value: "ALL", label: "الكل" },
  { value: "PENDING", label: "قيد الانتظار" },
  { value: "UNDER_REVIEW", label: "قيد المراجعة" },
  { value: "RESOLVED", label: "تم الحل" },
  { value: "REJECTED", label: "مرفوض" },
]

export function ReportFilters({
  value,
  onChange,
}: {
  value: ReportStatus | "ALL"
  onChange: (value: ReportStatus | "ALL") => void
}) {
  return (
    <div className="flex gap-1 overflow-x-auto rounded-lg bg-muted/50 p-1">
      {filters.map((filter) => (
        <button
          key={filter.value}
          type="button"
          onClick={() => onChange(filter.value)}
          className={cn(
            "shrink-0 rounded-md px-3 py-1.5 text-xs font-semibold transition-colors",
            value === filter.value
              ? "bg-background text-foreground shadow-sm"
              : "text-muted-foreground hover:text-foreground"
          )}
        >
          {filter.label}
        </button>
      ))}
    </div>
  )
}
