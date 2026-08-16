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
import {
  UserX,
  UserCheck,
  User,
  AtSign,
  Shield,
  Calendar,
  Clock,
} from "lucide-react"

import type { OrganizationBanResponse } from "@/lib/api/types"
import { getBannedUsers, unbanUserAction } from "@/lib/actions/members"

interface BannedUsersDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  slug: string
}

function formatDate(dateValue: string | Date | number | null | undefined) {
  if (!dateValue) return "غير متوفر"

  try {
    const date = new Date(dateValue)

    if (Number.isNaN(date.getTime())) {
      return "غير متوفر"
    }

    return new Intl.DateTimeFormat("ar-EG", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }).format(date)
  } catch {
    return "غير متوفر"
  }
}

function formatDateTime(dateValue: string | Date | number | null | undefined) {
  if (!dateValue) return "غير متوفر"

  try {
    const date = new Date(dateValue)

    if (Number.isNaN(date.getTime())) {
      return "غير متوفر"
    }

    return new Intl.DateTimeFormat("ar-EG", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date)
  } catch {
    return "غير متوفر"
  }
}

function getUserDisplayName(user: OrganizationBanResponse["user"]) {
  return user.name || user.username || "مستخدم"
}

function getUsername(user: OrganizationBanResponse["user"]) {
  return user.username ? `@${user.username}` : "غير متوفر"
}

function BannedUserDetailDialog({
  open,
  onOpenChange,
  ban,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  ban: OrganizationBanResponse | null
}) {
  if (!ban) return null

  const user = ban.user
  const displayName = getUserDisplayName(user)
  const username = getUsername(user)

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md" dir="rtl">
        <DialogTitle className="sr-only">معلومات المستخدم المحظور</DialogTitle>

        <div className="flex flex-col items-center space-y-6 p-6 pb-2">
          <div className="relative">
            <Image
              src={user.picture || "/default-avatar.png"}
              alt={displayName}
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
                {displayName}
              </h3>

              {user.username && (
                <p className="text-sm text-muted-foreground" dir="ltr">
                  @{user.username}
                </p>
              )}

              <p className="text-xs text-destructive/90">مستخدم محظور</p>
            </div>

            <div className="space-y-3 rounded-lg border border-border/40 bg-muted/50 p-4">
              <div className="flex items-center gap-3 text-sm">
                <User className="h-4 w-4 shrink-0 text-muted-foreground" />

                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">الاسم</p>

                  <p className="font-medium text-foreground">{displayName}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <AtSign className="h-4 w-4 shrink-0 text-muted-foreground" />

                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">اسم المستخدم</p>

                  <p className="font-medium text-foreground" dir="ltr">
                    {username}
                  </p>
                </div>
              </div>

              {user.email && (
                <div className="flex items-center gap-3 text-sm">
                  <div className="h-4 w-4 shrink-0" />

                  <div className="flex-1">
                    <p className="text-xs text-muted-foreground">
                      البريد الإلكتروني
                    </p>

                    <p
                      className="truncate font-medium text-foreground"
                      dir="ltr"
                    >
                      {user.email}
                    </p>
                  </div>
                </div>
              )}

              <div className="flex items-center gap-3 text-sm">
                <Shield className="h-4 w-4 shrink-0 text-muted-foreground" />

                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">سبب الحظر</p>

                  <p className="font-medium text-foreground">
                    {ban.reason || "لم يتم تحديد سبب"}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <Calendar className="h-4 w-4 shrink-0 text-muted-foreground" />

                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">تاريخ الحظر</p>

                  <p className="font-medium text-foreground">
                    {formatDate(ban.baseEntity?.createdAt)}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <Clock className="h-4 w-4 shrink-0 text-muted-foreground" />

                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">انتهاء الحظر</p>

                  <p className="font-medium text-foreground">
                    {ban.expiresAt ? formatDateTime(ban.expiresAt) : "دائم"}
                  </p>
                </div>
              </div>

              {ban.bannedByOrgAdmin && (
                <div className="border-t pt-3">
                  <p className="mb-1 text-xs text-muted-foreground">
                    تم الحظر بواسطة
                  </p>

                  <p className="text-sm font-medium text-foreground">
                    {ban.bannedByOrgAdmin.name ||
                      ban.bannedByOrgAdmin.username ||
                      "مسؤول المنظمة"}
                  </p>

                  {ban.bannedByOrgAdmin.username && (
                    <p className="text-xs text-muted-foreground" dir="ltr">
                      @{ban.bannedByOrgAdmin.username}
                    </p>
                  )}
                </div>
              )}

              {ban.bannedByAppAdmin && (
                <div className="border-t pt-3">
                  <p className="mb-1 text-xs text-muted-foreground">
                    تم الحظر بواسطة مسؤول التطبيق
                  </p>

                  <p className="text-sm font-medium text-foreground">
                    {ban.bannedByAppAdmin.name ||
                      ban.bannedByAppAdmin.username ||
                      "مسؤول التطبيق"}
                  </p>
                </div>
              )}
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
  const [bannedUsers, setBannedUsers] = useState<OrganizationBanResponse[]>([])

  const [loading, setLoading] = useState(false)

  const [userToUnban, setUserToUnban] =
    useState<OrganizationBanResponse | null>(null)

  const [selectedBannedUser, setSelectedBannedUser] =
    useState<OrganizationBanResponse | null>(null)

  const [unbanLoading, setUnbanLoading] = useState(false)
  useEffect(() => {
    if (!open) return

    let cancelled = false

    const fetchBannedUsers = async () => {
      try {
        const result = await getBannedUsers(slug, {
          page: 0,
          size: 50,
        })

        if (cancelled) return

        if (result.success && result.data) {
          setBannedUsers(result.data.content ?? [])
        } else {
          setBannedUsers([])
        }
      } catch (error) {
        if (cancelled) return

        console.error("Failed to fetch banned users:", error)
        setBannedUsers([])
      } finally {
        if (!cancelled) {
          setLoading(false)
        }
      }
    }

    fetchBannedUsers()

    return () => {
      cancelled = true
    }
  }, [open, slug])
  const handleUnban = async () => {
    if (!userToUnban) return

    setUnbanLoading(true)

    try {
      const result = await unbanUserAction(slug, userToUnban.user.id)

      if (result.success) {
        setBannedUsers((prev) =>
          prev.filter((ban) => ban.user.id !== userToUnban.user.id)
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

  return (
    <>
      <Dialog
        open={open}
        onOpenChange={(nextOpen) => {
          if (!nextOpen) {
            setBannedUsers([])
            setSelectedBannedUser(null)
            setUserToUnban(null)
            setLoading(false)
          } else {
            setLoading(true)
          }

          onOpenChange(nextOpen)
        }}
      >
        <DialogContent
          className="flex h-[85vh] w-full flex-col gap-0 overflow-hidden border-muted/50 p-0 shadow-lg sm:h-[600px] sm:max-w-[420px] sm:rounded-xl"
          dir="rtl"
        >
          <div className="flex h-14 shrink-0 items-center justify-center border-b bg-muted/30 p-4 pb-3">
            <DialogTitle className="flex items-center gap-2 text-[15px] font-bold tracking-wide">
              <UserX className="h-4 w-4" />
              المستخدمون المحظورون
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
                      className="hidden opacity-40 mix-blend-luminosity grayscale invert dark:invert-0"
                    />

                    <span>لا يوجد مستخدمون محظورون.</span>
                  </div>
                ) : (
                  bannedUsers.map((ban) => {
                    const user = ban.user
                    const displayName = getUserDisplayName(user)

                    return (
                      <div
                        key={ban.id}
                        onClick={() => setSelectedBannedUser(ban)}
                        className="group flex cursor-pointer items-center gap-3 rounded-lg border-b border-muted/20 bg-background/60 p-3 transition-all duration-150 hover:bg-muted/40 hover:shadow-sm active:scale-[0.98]"
                      >
                        <Image
                          src={user.picture || "/default-avatar.png"}
                          alt={displayName}
                          width={38}
                          height={38}
                          className="shrink-0 rounded-full object-cover ring-2 ring-transparent transition-all group-hover:ring-border/40"
                        />

                        <div className="flex min-w-0 flex-1 flex-col">
                          <span className="truncate text-sm font-semibold tracking-tight text-foreground">
                            {displayName}
                          </span>

                          {user.username && (
                            <span
                              className="truncate text-xs text-muted-foreground"
                              dir="ltr"
                            >
                              @{user.username}
                            </span>
                          )}

                          {ban.reason && (
                            <span className="mt-1 truncate text-xs text-destructive/70">
                              السبب: {ban.reason}
                            </span>
                          )}

                          <span className="mt-1 text-xs text-muted-foreground">
                            الحظر: {formatDate(ban.baseEntity?.createdAt)}
                          </span>

                          <span className="text-xs text-muted-foreground">
                            {ban.expiresAt
                              ? `ينتهي: ${formatDate(ban.expiresAt)}`
                              : "حظر دائم"}
                          </span>
                        </div>

                        <div className="shrink-0">
                          <Button
                            variant="outline"
                            size="sm"
                            className="h-7 gap-1 px-3 text-xs"
                            onClick={(e) => {
                              e.stopPropagation()
                              setUserToUnban(ban)
                            }}
                          >
                            <UserCheck className="h-3 w-3" />
                            فك الحظر
                          </Button>
                        </div>
                      </div>
                    )
                  })
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
              <strong className="mx-1">
                {userToUnban ? getUserDisplayName(userToUnban.user) : ""}
              </strong>
              ؟
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
          if (!open) {
            setSelectedBannedUser(null)
          }
        }}
        ban={selectedBannedUser}
      />
    </>
  )
}
