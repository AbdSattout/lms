"use client"

import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Shield, User, AtSign, Mail, Phone, GraduationCap } from "lucide-react"
import type { OrganizationMemberResponse } from "@/lib/api/types"

interface MemberDetailDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  member: OrganizationMemberResponse | null
}

export function MemberDetailDialog({
  open,
  onOpenChange,
  member,
}: MemberDetailDialogProps) {
  if (!member) return null

  const userData = member.user
  const isAdmin = member.role === "ADMIN" || member.role === "OWNER"

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md" dir="rtl">
        <DialogTitle className="sr-only">
          {isAdmin ? "معلومات المشرف" : "معلومات الطالب"}
        </DialogTitle>

        <div className="flex flex-col items-center space-y-6 p-6">
          <div className="relative">
            <Image
              src={userData.picture || "/default-avatar.png"}
              alt={userData.name || "Member"}
              width={100}
              height={100}
              className="rounded-full object-cover ring-4 ring-muted"
            />
            <div className="absolute -right-1 -bottom-1 rounded-full bg-primary p-1.5 text-primary-foreground">
              {isAdmin ? (
                <Shield className="h-4 w-4" />
              ) : (
                <GraduationCap className="h-4 w-4" />
              )}
            </div>
          </div>

          <div className="w-full space-y-4">
            <div className="space-y-1 text-center">
              <h3 className="text-xl font-bold text-foreground">
                {userData.name}
              </h3>
              <p className="text-xs text-muted-foreground">
                {isAdmin ? "مشرف" : "طالب"}
              </p>
            </div>

            <div className="space-y-3 rounded-lg bg-muted/50 p-4">
              {/* Name */}
              <div className="flex items-center gap-3 text-sm">
                <User className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">الاسم</p>
                  <p className="font-medium text-foreground">{userData.name}</p>
                </div>
              </div>

              {/* Username */}
              <div className="flex items-center gap-3 text-sm">
                <AtSign className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">اسم المستخدم</p>
                  <p
                    className={`font-medium text-foreground ${userData.username ? "ltr" : ""}`}
                    dir={userData.username ? "ltr" : "rtl"}
                  >
                    {userData.username ? `@${userData.username}` : "غير متوفر"}
                  </p>
                </div>
              </div>

              {/* Email */}
              <div className="flex items-center gap-3 text-sm">
                <Mail className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">
                    البريد الإلكتروني
                  </p>
                  <p
                    className={`font-medium text-foreground ${userData.email ? "ltr" : ""}`}
                    dir={userData.email ? "ltr" : "rtl"}
                  >
                    {userData.email || "غير متوفر"}
                  </p>
                </div>
              </div>

              {/* Phone Number */}
              <div className="flex items-center gap-3 text-sm">
                <Phone className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">رقم الهاتف</p>
                  <p
                    className={`font-medium text-foreground ${userData.phoneNumber ? "ltr" : ""}`}
                    dir={userData.phoneNumber ? "ltr" : "rtl"}
                  >
                    {userData.phoneNumber || "غير متوفر"}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
