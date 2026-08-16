"use client"

import { useMemo, useState } from "react"
import { ChevronRight, FileWarning, Inbox } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"

import type { ReportResponse, ReportStatus } from "@/lib/api/types"

import { ReportDetails } from "./report-details"
import { ReportFilters } from "./report-filters"
import { ReportListItem } from "./report-list-item"

interface ReportsPageProps {
  initialReports: ReportResponse[]
  totalElements: number
}

export function ReportsPage({
  initialReports,
  totalElements,
}: ReportsPageProps) {
  const [reports, setReports] = useState(initialReports)
  const [selectedId, setSelectedId] = useState<number | null>(
    initialReports[0]?.id ?? null
  )
  const [status, setStatus] = useState<ReportStatus | "ALL">("ALL")

  const visibleReports = useMemo(() => {
    if (status === "ALL") return reports

    return reports.filter((report) => report.status === status)
  }, [reports, status])

  const selectedReport =
    reports.find((report) => report.id === selectedId) ?? null

  function handleUpdated(updated: ReportResponse) {
    setReports((current) =>
      current.map((report) => (report.id === updated.id ? updated : report))
    )
  }

  function selectFilter(nextStatus: ReportStatus | "ALL") {
    setStatus(nextStatus)

    const filtered =
      nextStatus === "ALL"
        ? reports
        : reports.filter((report) => report.status === nextStatus)

    if (selectedId && !filtered.some((report) => report.id === selectedId)) {
      setSelectedId(filtered[0]?.id ?? null)
    }
  }

  return (
    <div className="flex h-screen min-h-0 flex-col overflow-hidden">
      <header className="shrink-0 border-b bg-card">
        <div className="flex h-16 items-center justify-between gap-4 px-4 md:px-6">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
              <FileWarning className="h-5 w-5 text-primary" />
            </div>

            <div>
              <h1 className="font-bold">البلاغات</h1>
              <p className="text-xs text-muted-foreground">
                مراجعة المحتوى المبلغ عنه
              </p>
            </div>
          </div>

          <div className="hidden rounded-full bg-muted px-3 py-1.5 text-xs font-semibold text-muted-foreground sm:block">
            {totalElements} بلاغ
          </div>
        </div>
      </header>

      <div className="flex min-h-0 flex-1">
        <aside className="flex w-full shrink-0 flex-col border-l bg-card md:w-[380px] xl:w-[420px]">
          <div className="shrink-0 border-b p-3">
            <ReportFilters value={status} onChange={selectFilter} />
          </div>

          <div className="min-h-0 flex-1 overflow-y-auto">
            {visibleReports.length === 0 ? (
              <div className="flex h-full flex-col items-center justify-center p-8 text-center">
                <Inbox className="h-10 w-10 text-muted-foreground/50" />

                <p className="mt-3 text-sm font-semibold">لا توجد بلاغات</p>

                <p className="mt-1 text-xs text-muted-foreground">
                  لا توجد بلاغات ضمن الفلتر الحالي.
                </p>
              </div>
            ) : (
              visibleReports.map((report) => (
                <ReportListItem
                  key={report.id}
                  report={report}
                  selected={report.id === selectedId}
                  onClick={() => setSelectedId(report.id)}
                />
              ))
            )}
          </div>
        </aside>

        <section className="hidden min-w-0 flex-1 overflow-y-auto bg-background md:block">
          {selectedReport ? (
            <ReportDetails
              key={selectedReport.id}
              initialReport={selectedReport}
              onUpdated={handleUpdated}
            />
          ) : (
            <EmptyDetails />
          )}
        </section>

        <section className="fixed inset-0 z-50 hidden bg-background md:hidden">
          {selectedReport && (
            <>
              <div className="flex h-14 items-center border-b px-4">
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setSelectedId(null)}
                >
                  <ChevronRight className="h-5 w-5" />
                </Button>

                <span className="mr-2 text-sm font-bold">مراجعة البلاغ</span>
              </div>

              <div className="h-[calc(100%-3.5rem)] overflow-y-auto">
                <ReportDetails
                  key={selectedReport.id}
                  initialReport={selectedReport}
                  onUpdated={handleUpdated}
                />
              </div>
            </>
          )}
        </section>
      </div>

      <Separator className="md:hidden" />
    </div>
  )
}

function EmptyDetails() {
  return (
    <div className="flex h-full flex-col items-center justify-center p-8 text-center">
      <div className="flex h-14 w-14 items-center justify-center rounded-full bg-muted">
        <FileWarning className="h-6 w-6 text-muted-foreground" />
      </div>

      <h2 className="mt-4 text-lg font-bold">اختر بلاغاً للمراجعة</h2>

      <p className="mt-1 max-w-sm text-sm leading-6 text-muted-foreground">
        اختر إحدى الحالات من القائمة لعرض سبب البلاغ والمحتوى المرتبط به
        وإجراءات المراجعة.
      </p>
    </div>
  )
}
