"use client"

import { cn } from "@/lib/utils"
import type { ReportResponse } from "@/lib/api/types"

import { ReportStatusBadge } from "./report-status-badge"
import { ReportTargetLabel } from "./report-target-label"

interface ReportListItemProps {
  report: ReportResponse
  selected: boolean
  onClick: () => void
}

export function ReportListItem({
  report,
  selected,
  onClick,
}: ReportListItemProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "w-full border-b border-border/60 px-4 py-4 text-right transition-colors",
        "hover:bg-muted/50",
        selected &&
          "bg-primary/[0.06] shadow-[inset_-3px_0_0_hsl(var(--primary))]"
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <div className="mb-2 flex items-center gap-2">
            <ReportTargetLabel targetType={report.targetType} />
          </div>

          <p className="line-clamp-2 text-sm leading-6 font-semibold text-foreground">
            {report.reason}
          </p>

          <div className="mt-2 flex items-center gap-2 text-xs text-muted-foreground">
            <span>{report.reporter.name}</span>
          </div>
        </div>

        <ReportStatusBadge status={report.status} />
      </div>
    </button>
  )
}
