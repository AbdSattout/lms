"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { UserX, UserCheck, User, AtSign, Mail, Phone } from "lucide-react"
import type { OrganizationBannedUserResponse } from "@/lib/api/types"
import { getBannedUsers, unbanUserAction } from "@/lib/actions/members"

interface BannedUsersDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  slug: string
}

function BannedUserDetailDialog({
  open,
  onOpenChange,
  user,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  user: OrganizationBannedUserResponse | null
}) {
  if (!user) return null

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md" dir="rtl">
        <DialogTitle className="sr-only">معلومات الطالب المحظور</DialogTitle>

        <div className="flex flex-col items-center space-y-6 p-6 pb-2">
          <div className="relative">
            <Image
              src={user.avatarUrl || "/default-avatar.png"}
              alt={user.username || "User avatar"}
              width={100}
              height={100}
              className="rounded-full object-cover ring-4 ring-muted"
            />
            <div className="text-destructive-foreground absolute -right-1 -bottom-1 rounded-full bg-destructive p-1.5 shadow-sm">
              <UserX className="h-4 w-4" />
            </div>
          </div>

          <div className="w-full space-y-4">
            <div className="space-y-1 text-center">
              <h3 className="text-xl font-bold text-foreground">
                {user.username}
              </h3>
              <p className="text-xs text-destructive/90">طالب (محظور)</p>
            </div>

            <div className="space-y-3 rounded-lg border border-border/40 bg-muted/50 p-4">
              <div className="flex items-center gap-3 text-sm">
                <User className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">الاسم</p>
                  <p className="font-medium text-foreground">{user.username}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <AtSign className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">اسم المستخدم</p>
                  <p
                    className="text-left font-medium text-foreground"
                    dir="ltr"
                  >
                    @{user.username || "غير متوفر"}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <Mail className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">
                    البريد الإلكتروني
                  </p>
                  <p
                    className={`font-medium text-foreground ${user.email ? "ltr" : ""}`}
                    dir={user.email ? "ltr" : "rtl"}
                  >
                    {user.email || "غير متوفر"}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <Phone className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">رقم الهاتف</p>
                  <p className="font-medium text-foreground text-muted-foreground/60">
                    غير متوفر
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

export function BannedUsersDialog({
  open,
  onOpenChange,
  slug,
}: BannedUsersDialogProps) {
  const [bannedUsers, setBannedUsers] = useState<
    OrganizationBannedUserResponse[]
  >([])
  const [loading, setLoading] = useState(false)
  const [userToUnban, setUserToUnban] =
    useState<OrganizationBannedUserResponse | null>(null)

  const [selectedBannedUser, setSelectedBannedUser] =
    useState<OrganizationBannedUserResponse | null>(null)

  const [unbanLoading, setUnbanLoading] = useState(false)

  useEffect(() => {
    const fetchBannedUsers = async () => {
      setLoading(true)
      try {
        const result = await getBannedUsers(slug, { page: 0, size: 50 })
        if (result.success && result.data) {
          setBannedUsers(result.data.content ?? [])
        }
      } catch (error) {
        console.error("Failed to fetch banned users:", error)
      } finally {
        setLoading(false)
      }
    }

    if (open) {
      fetchBannedUsers()
    } else {
      setTimeout(() => {
        setBannedUsers([])
      }, 200)
    }
  }, [open, slug])

  const handleUnban = async () => {
    if (!userToUnban) return
    setUnbanLoading(true)

    try {
      const result = await unbanUserAction(slug, userToUnban.userId)
      if (result.success) {
        setBannedUsers((prev) =>
          prev.filter((u) => u.userId !== userToUnban.userId)
        )
        setUserToUnban(null)
      } else {
        console.error("Failed to unban user:", result.error)
      }
    } catch (error) {
      console.error("Failed to unban user:", error)
    } finally {
      setUnbanLoading(false)
    }
  }

  const formatDate = (dateData: Date | string | number | null | undefined) => {
    try {
      if (!dateData) return "غير متوفر"

      let dateObj: Date
      if (Array.isArray(dateData)) {
        dateObj = new Date(
          dateData[0],
          (dateData[1] || 1) - 1,
          dateData[2] || 1,
          dateData[3] || 0,
          dateData[4] || 0,
          dateData[5] || 0
        )
      } else {
        dateObj = new Date(dateData)
      }

      if (isNaN(dateObj.getTime())) return "غير متوفر"

      return new Intl.DateTimeFormat("ar-EG", {
        year: "numeric",
        month: "long",
        day: "numeric",
      }).format(dateObj)
    } catch {
      return "صيغة غير صحيحة"
    }
  }

  return (
    <>
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent
          className="flex h-[85vh] w-full flex-col gap-0 overflow-hidden border-muted/50 p-0 shadow-lg sm:h-[600px] sm:max-w-[420px] sm:rounded-xl"
          dir="rtl"
        >
          <div className="flex h-14 shrink-0 items-center justify-center border-b bg-muted/30 p-4 pb-3">
            <DialogTitle className="flex items-center gap-2 text-[15px] font-bold tracking-wide">
              <UserX className="h-4 w-4" />
              الطلاب المحظورين
            </DialogTitle>
          </div>

          <div className="relative flex min-h-0 flex-1 flex-col bg-background/50">
            {loading ? (
              <div className="flex h-full animate-pulse items-center justify-center text-xs font-semibold text-muted-foreground">
                جاري تحميل القائمة...
              </div>
            ) : (
              <div className="custom-scrollbar h-full space-y-1 overflow-y-auto p-3">
                {bannedUsers.length === 0 ? (
                  <div className="flex h-full flex-col items-center justify-center space-y-2 text-sm font-medium text-muted-foreground opacity-70">
                    <Image
                      src="/no-results.png"
                      alt="No Result"
                      width={100}
                      height={100}
                      className="block hidden opacity-40 mix-blend-luminosity grayscale invert dark:invert-0"
                    />
                    <span>لا يوجد طلاب محظورين.</span>
                  </div>
                ) : (
                  bannedUsers.map((user) => (
                    <div
                      key={user.userId}
                      onClick={() => setSelectedBannedUser(user)}
                      className="group flex cursor-pointer items-center gap-3 rounded-lg border-b border-muted/20 bg-background/60 p-3 transition-all duration-150 hover:bg-muted/40 hover:shadow-sm active:scale-[0.98]"
                    >
                      <Image
                        src={user.avatarUrl || "/default-avatar.png"}
                        alt={user.username || "User avatar"}
                        width={38}
                        height={38}
                        className="shrink-0 rounded-full object-cover ring-2 ring-transparent transition-all group-hover:ring-border/40"
                      />
                      <div className="flex flex-1 flex-col truncate">
                        <span className="truncate text-sm font-semibold tracking-tight text-foreground">
                          {user.username}
                        </span>
                        {user.email && (
                          <span
                            className="truncate text-xs text-muted-foreground"
                            dir="ltr"
                          >
                            {user.email}
                          </span>
                        )}
                        {user.banReason && (
                          <span className="mt-1 truncate text-xs text-destructive/70">
                            السبب: {user.banReason}
                          </span>
                        )}
                        <span className="mt-1 text-xs text-muted-foreground">
                          حظر بتاريخ: {formatDate(user.bannedAt)}
                        </span>
                      </div>

                      <div className="shrink-0">
                        <Button
                          variant="outline"
                          size="sm"
                          className="h-7 gap-1 px-3 text-xs"
                          onClick={(e) => {
                            e.stopPropagation()
                            setUserToUnban(user)
                          }}
                        >
                          <UserCheck className="h-3 w-3" />
                          فك الحظر
                        </Button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>

      <AlertDialog
        open={!!userToUnban}
        onOpenChange={(open) => {
          if (!open && !unbanLoading) {
            setUserToUnban(null)
          }
        }}
      >
        <AlertDialogContent dir="rtl">
          <AlertDialogHeader>
            <AlertDialogTitle>تأكيد فك الحظر</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد أنك تريد فك الحظر عن
              <strong className="mx-1">{userToUnban?.username}</strong>؟
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="flex gap-2">
            <AlertDialogCancel disabled={unbanLoading}>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={(e) => {
                e.preventDefault()
                handleUnban()
              }}
              disabled={unbanLoading}
              className="bg-primary text-primary-foreground hover:bg-primary/90"
            >
              {unbanLoading ? "جاري المعالجة..." : "تأكيد فك الحظر"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <BannedUserDetailDialog
        open={!!selectedBannedUser}
        onOpenChange={(open) => {
          if (!open) setSelectedBannedUser(null)
        }}
        user={selectedBannedUser}
      />
    </>
  )
}
