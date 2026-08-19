import { getCurrentAdminAction } from "@/lib/actions/admin-moderators"
import { ModeratorsPage } from "./moderators-page"
import { redirect } from "next/navigation"

export default async function AdminModeratorsPage() {
  const admin = await getCurrentAdminAction()

  if (admin.role !== "SUPER_ADMIN") {
    redirect("/admin/reports")
  }
  return <ModeratorsPage />
}
