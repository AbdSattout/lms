import { AdminSidebar } from "@/components/admin/admin-sidebar"
import type { ReactNode } from "react"

export default function AdminLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-muted/20" dir="rtl">
      <div className="flex min-h-screen">
        <AdminSidebar />

        <main className="min-w-0 flex-1">{children}</main>
      </div>
    </div>
  )
}
