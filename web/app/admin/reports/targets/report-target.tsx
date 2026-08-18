import type { ReportResponse } from "@/lib/api/types"

import { OrganizationReportTarget } from "./organization-report-target"
import { UserReportTarget } from "./user-report-target"
import { PostReportTarget } from "./post-report-target"
import { CommentReportTarget } from "./comment-report-target"

export function ReportTarget({ report }: { report: ReportResponse }) {
  if (!report.target.exists) {
    return (
      <div className="rounded-xl border border-dashed p-8 text-center">
        <p className="text-sm font-semibold">المحتوى لم يعد متاحاً</p>

        <p className="mt-1 text-xs text-muted-foreground">
          المحتوى المرتبط بهذا البلاغ تم حذفه أو لم يعد موجوداً.
        </p>
      </div>
    )
  }

  switch (report.targetType) {
    case "POST":
      if (
        report.target.organizationId == null ||
        report.target.postId == null
      ) {
        return <MissingTargetData />
      }

      return (
        <PostReportTarget
          organizationId={report.target.organizationId}
          postId={report.target.postId}
        />
      )

    case "COMMENT":
      if (report.target.commentId == null) {
        return <MissingTargetData />
      }

      return <CommentReportTarget commentId={report.target.commentId} />

    case "USER":
      if (report.target.userId == null) {
        return <MissingTargetData />
      }

      return <UserReportTarget userId={report.target.userId} />

    case "ORGANIZATION":
      if (report.target.organizationId == null) {
        return <MissingTargetData />
      }

      return (
        <OrganizationReportTarget
          organizationId={report.target.organizationId}
        />
      )

    default:
      return null
  }
}

function MissingTargetData() {
  return (
    <div className="rounded-xl border border-dashed p-8 text-center">
      <p className="text-sm font-semibold">بيانات المحتوى غير مكتملة</p>

      <p className="mt-1 text-xs text-muted-foreground">
        لم يُرجع الـ backend المعرف المطلوب لهذا البلاغ.
      </p>
    </div>
  )
}
