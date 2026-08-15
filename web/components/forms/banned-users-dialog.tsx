// components/banned-users-dialog.tsx
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
import { UserX, UserCheck } from "lucide-react"
import type { OrganizationBannedUserResponse } from "@/lib/api/types"
import { getBannedUsers, unbanUserAction } from "@/lib/actions/members"

interface BannedUsersDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  slug: string
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

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("ar", {
      year: "numeric",
      month: "long",
      day: "numeric",
    })
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
                      className="group flex items-center gap-3 rounded-lg border-b border-muted/20 bg-background/60 p-3 transition-all duration-150 hover:bg-muted/40 hover:shadow-sm"
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
                      <Button
                        variant="outline"
                        size="sm"
                        className="h-7 gap-1 px-3 text-xs"
                        onClick={() => setUserToUnban(user)}
                      >
                        <UserCheck className="h-3 w-3" />
                        فك الحظر
                      </Button>
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
              className="bg-primary hover:bg-primary/90"
            >
              {unbanLoading ? "جاري المعالجة..." : "تأكيد فك الحظر"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
