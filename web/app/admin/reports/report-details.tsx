"use client"

import { useState, useTransition } from "react"
import { CheckCircle2, Clock3, FileWarning, XCircle } from "lucide-react"
import { toast } from "sonner"

import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Textarea } from "@/components/ui/textarea"

import type { ReportResponse, ReportStatus } from "@/lib/api/types"

import { ReportStatusBadge } from "./report-status-badge"
import { ReportTarget } from "./targets/report-target"
import { reviewAdminReportAction } from "@/lib/actions/admin"

interface ReportDetailsProps {
  initialReport: ReportResponse
  onUpdated: (report: ReportResponse) => void
}

export function ReportDetails({
  initialReport,
  onUpdated,
}: ReportDetailsProps) {
  const [report, setReport] = useState(initialReport)
  const [adminNote, setAdminNote] = useState(initialReport.adminNote ?? "")
  const [isSubmitting, startSubmit] = useTransition()

  async function updateStatus(status: ReportStatus) {
    startSubmit(async () => {
      try {
        const updated = await reviewAdminReportAction(report.id, {
          status,
          adminNote: adminNote.trim() || null,
        })

        setReport(updated)
        onUpdated(updated)

        toast.success("تم تحديث البلاغ بنجاح")
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "فشل تحديث البلاغ")
      }
    })
  }

  const targetId = getReportTargetId(report)

  return (
    <div className="flex min-w-0 flex-col gap-5 p-4 md:p-6 lg:p-8">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <FileWarning className="h-5 w-5 text-primary" />

            <p className="text-sm font-semibold text-muted-foreground">
              مراجعة البلاغ
            </p>
            <ReportStatusBadge status={report.status} />
          </div>

          <h1 className="mt-2 text-2xl font-extrabold tracking-tight">
            مراجعة البلاغ
          </h1>
        </div>
      </div>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">معلومات البلاغ</CardTitle>
        </CardHeader>

        <CardContent className="space-y-5">
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarFallback>
                {report.reporter.name.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>

            <div>
              <p className="text-sm font-bold">{report.reporter.name}</p>

              {report.reporter.username && (
                <p className="text-xs text-muted-foreground">
                  @{report.reporter.username}
                </p>
              )}
            </div>
          </div>

          <Separator />

          <div>
            <p className="text-xs font-bold text-muted-foreground">
              سبب البلاغ
            </p>

            <p className="mt-2 rounded-lg bg-muted/50 p-4 text-sm leading-6">
              {report.reason}
            </p>
          </div>

          <div className="grid gap-4 text-sm sm:grid-cols-2">
            <InfoRow label="نوع البلاغ">{report.targetType}</InfoRow>

            <InfoRow label="الحالة الحالية">
              <ReportStatusBadge status={report.status} />
            </InfoRow>

            <InfoRow label="تاريخ البلاغ">
              {report.baseEntityResponse?.createdAt
                ? new Date(report.baseEntityResponse.createdAt).toLocaleString(
                    "ar"
                  )
                : "—"}
            </InfoRow>
          </div>
        </CardContent>
      </Card>

      <section>
        <div className="mb-3 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold">المحتوى المبلغ عنه</h2>

            <p className="text-sm text-muted-foreground">
              عرض الأدلة المتاحة من النظام
            </p>
          </div>
        </div>

        <ReportTarget report={report} />
      </section>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">قرار المشرف</CardTitle>
        </CardHeader>

        <CardContent className="space-y-4">
          {report.status === "RESOLVED" || report.status === "REJECTED" ? (
            <div className="space-y-4">
              <div
                className={
                  report.status === "RESOLVED"
                    ? "rounded-lg border border-emerald-200 bg-emerald-50/60 p-4 dark:border-emerald-900 dark:bg-emerald-950/20"
                    : "rounded-lg border border-border bg-muted/40 p-4"
                }
              >
                <div className="flex items-center justify-between gap-3">
                  <p className="text-sm font-bold">
                    {report.status === "RESOLVED"
                      ? "تم حل البلاغ"
                      : "تم رفض البلاغ"}
                  </p>

                  <ReportStatusBadge status={report.status} />
                </div>

                {report.adminNote && (
                  <p className="mt-3 text-sm leading-6 text-muted-foreground">
                    {report.adminNote}
                  </p>
                )}

                {report.adminResponse && (
                  <div className="mt-4 border-t border-border/50 pt-3">
                    <p className="text-xs font-bold text-muted-foreground">
                      تمت المراجعة بواسطة
                    </p>

                    <p className="mt-1 text-sm font-semibold">
                      {report.adminResponse.name}
                    </p>

                    {report.reviewedAt && (
                      <p className="mt-1 text-xs text-muted-foreground">
                        {new Date(report.reviewedAt).toLocaleString("ar")}
                      </p>
                    )}
                  </div>
                )}
              </div>
            </div>
          ) : (
            <>
              <Textarea
                value={adminNote}
                onChange={(event) => setAdminNote(event.target.value)}
                placeholder="اكتب ملاحظة حول قرارك..."
                className="min-h-28 resize-y"
                disabled={isSubmitting}
                dir="rtl"
              />

              <div className="flex flex-wrap items-center justify-end gap-2">
                <Button
                  variant="outline"
                  disabled={isSubmitting || report.status === "UNDER_REVIEW"}
                  onClick={() => updateStatus("REJECTED")}
                >
                  <XCircle className="ml-2 h-4 w-4" />
                  رفض البلاغ
                </Button>

                <Button
                  variant="secondary"
                  disabled={isSubmitting || report.status === "UNDER_REVIEW"}
                  onClick={() => updateStatus("UNDER_REVIEW")}
                >
                  <Clock3 className="ml-2 h-4 w-4" />
                  قيد المراجعة
                </Button>

                <Button
                  disabled={isSubmitting}
                  onClick={() => updateStatus("RESOLVED")}
                >
                  <CheckCircle2 className="ml-2 h-4 w-4" />
                  حل البلاغ
                </Button>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function getReportTargetId(report: ReportResponse): number | null {
  switch (report.targetType) {
    case "POST":
      return report.target.postId ?? null

    case "COMMENT":
      return report.target.commentId ?? null

    case "USER":
      return report.target.userId ?? null

    case "ORGANIZATION":
      return report.target.organizationId ?? null

    case "COURSE":
      return report.target.courseId ?? null

    default:
      return null
  }
}

function InfoRow({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-bold text-muted-foreground">{label}</p>

      <div className="text-sm font-semibold">{children}</div>
    </div>
  )
}
