import { getAdminReportsAction } from "@/lib/actions/admin"
import { ReportsPage } from "./report-page"

export default async function AdminReportsPage() {
  const reports = await getAdminReportsAction({
    page: 0,
    size: 20,
  })

  return (
    <ReportsPage
      initialReports={reports.content ?? []}
      totalElements={reports.totalElements ?? 0}
    />
  )
}
