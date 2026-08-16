import type { ReportResponse } from "@/lib/api/types"

import { OrganizationReportTarget } from "./organization-report-target"
import { UserReportTarget } from "./user-report-target"

export function ReportTarget({ report }: { report: ReportResponse }) {
  switch (report.targetType) {
    case "ORGANIZATION":
      return <OrganizationReportTarget organizationId={report.targetId} />

    case "USER":
      return <UserReportTarget userId={report.targetId} />

    case "COMMENT":
      return (
        <div className="rounded-xl border border-dashed border-amber-300 bg-amber-50/50 p-8 text-center dark:border-amber-900 dark:bg-amber-950/20">
          <p className="text-sm font-semibold">تفاصيل التعليق غير متاحة بعد</p>

          <p className="mt-1 text-xs text-muted-foreground">
            واجهة الـ backend الخاصة بجلب التعليق قيد التنفيذ.
          </p>
        </div>
      )

    case "POST":
      return (
        <div className="rounded-xl border border-dashed border-amber-300 bg-amber-50/50 p-8 text-center dark:border-amber-900 dark:bg-amber-950/20">
          <p className="text-sm font-semibold">
            لا يمكن تحميل المنشور من بيانات البلاغ الحالية
          </p>

          <p className="mt-1 text-xs leading-6 text-muted-foreground">
            نقطة الإدارة الحالية تتطلب organizationId + postId، بينما البلاغ
            يرسل postId فقط.
          </p>
        </div>
      )

    default:
      return null
  }
}
