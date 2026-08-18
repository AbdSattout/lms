"use client"

import type { Route } from "next"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  BadgeCheck,
  Ban,
  FileWarning,
  LogOut,
  Settings,
  ShieldCheck,
  Users,
} from "lucide-react"

import { Separator } from "@/components/ui/separator"
import { cn } from "@/lib/utils"
import { LogoutButton } from "../auth/logout-button"

export function AdminSidebar() {
  const pathname = usePathname()

  const isReportsActive = pathname.startsWith("/admin/reports")
  const isBansActive = pathname.startsWith("/admin/bans")
  const isVerificationsActive = pathname.startsWith(
    "/admin/organization-verifications"
  )

  return (
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
            className={cn(
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition-colors",
              isReportsActive
                ? "bg-primary/10 text-primary"
                : "text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
          >
            <FileWarning className="h-4 w-4" />
            البلاغات
          </Link>

          <Link
            href={"/admin/bans" as Route}
            className={cn(
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition-colors",
              isBansActive
                ? "bg-primary/10 text-primary"
                : "text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
          >
            <Ban className="h-4 w-4" />
            الحظر
          </Link>
          <Link
            href={"/admin/moderators" as Route}
            className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <Users className="h-4 w-4" />
            المشرفون
          </Link>
          <Link
            href={"/admin/organization-verifications" as Route}
            className={cn(
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition-colors",
              isVerificationsActive
                ? "bg-primary/10 text-primary"
                : "text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
          >
            <BadgeCheck className="h-4 w-4" />
            Organization verification
          </Link>

          <div className="mt-auto flex flex-col gap-1">
            <LogoutButton
              variant="ghost"
              className="w-full justify-start gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
            >
              <LogOut className="h-4 w-4" />
              تسجيل الخروج
            </LogoutButton>
          </div>
        </nav>
      </div>
    </aside>
  )
}
