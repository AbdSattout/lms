import type { ReactNode } from "react"
import Link from "next/link"
import {
  FileWarning,
  ShieldCheck,
  Users,
  Building2,
  Ban,
  Settings,
} from "lucide-react"

import { Separator } from "@/components/ui/separator"
import { Route } from "next"

export default function AdminLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-muted/20" dir="rtl">
      <div className="flex min-h-screen">
        <aside className="hidden w-[250px] shrink-0 border-l bg-card lg:flex">
          <div className="flex w-full flex-col">
            <div className="flex h-16 items-center gap-3 px-5">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary text-primary-foreground">
                <ShieldCheck className="h-5 w-5" />
              </div>

              <div>
                <p className="text-sm font-bold">لوحة الإدارة</p>
                <p className="text-xs text-muted-foreground">مركز LMS</p>
              </div>
            </div>

            <Separator />

            <nav className="flex flex-1 flex-col gap-1 p-3">
              <p className="px-3 pt-3 pb-2 text-[11px] font-bold tracking-wider text-muted-foreground">
                الإشراف
              </p>

              <Link
                href={"/admin/reports" as Route}
                className="flex items-center gap-3 rounded-lg bg-primary/10 px-3 py-2.5 text-sm font-semibold text-primary"
              >
                <FileWarning className="h-4 w-4" />
                البلاغات
              </Link>

              <div className="mt-1 flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground">
                <Ban className="h-4 w-4" />
                الحظر
                <span className="mr-auto rounded-full bg-muted px-2 py-0.5 text-[10px]">
                  لاحقاً
                </span>
              </div>

              <p className="px-3 pt-6 pb-2 text-[11px] font-bold tracking-wider text-muted-foreground">
                الإدارة
              </p>

              <div className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground">
                <Users className="h-4 w-4" />
                المشرفون
                <span className="mr-auto rounded-full bg-muted px-2 py-0.5 text-[10px]">
                  لاحقاً
                </span>
              </div>

              <div className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground">
                <Building2 className="h-4 w-4" />
                المنظمات
              </div>

              <div className="mt-auto flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground">
                <Settings className="h-4 w-4" />
                الإعدادات
              </div>
            </nav>
          </div>
        </aside>

        <main className="min-w-0 flex-1">{children}</main>
      </div>
    </div>
  )
}
