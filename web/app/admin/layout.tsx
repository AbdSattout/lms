import type { ReactNode } from "react"

import { getCurrentAdminAction } from "@/lib/actions/admin-moderators"
import { AdminSidebar } from "@/components/admin/admin-sidebar"

export default async function AdminLayout({
  children,
}: {
  children: ReactNode
}) {
  const admin = await getCurrentAdminAction()

  const isSuperAdmin = admin.role === "SUPER_ADMIN"

  return (
    <div className="min-h-screen bg-muted/20" dir="rtl">
      <div className="flex min-h-screen">
        <AdminSidebar isSuperAdmin={isSuperAdmin} />

        <main className="min-w-0 flex-1">{children}</main>
      </div>
    </div>
  )
}
