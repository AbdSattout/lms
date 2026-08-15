"use client"

import { useState } from "react"
import { Bell, Check, X, Loader2 } from "lucide-react"

import { OrganizationInviteResponse } from "@/lib/api/types"
import {
  getMyPendingInvitesAction,
  acceptInviteAction,
  declineInviteAction,
} from "@/lib/actions/invites"
import { cn } from "@/lib/utils"
import { InviteDetailDialog } from "../forms/invite-detial-dialog"
import { toast } from "sonner"
import { useRouter } from "next/dist/client/components/navigation"

export function Notifications() {
  const [isOpen, setIsOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])
  const [processingInvites, setProcessingInvites] = useState<Set<number>>(
    new Set()
  )
  const [selectedInvite, setSelectedInvite] =
    useState<OrganizationInviteResponse | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)
  const router = useRouter()
  const handleToggle = async () => {
    const willOpen = !isOpen
    setIsOpen(willOpen)

    if (willOpen) {
      setIsLoading(true)
      const data = await getMyPendingInvitesAction()
      setInvites(data)
      setIsLoading(false)
    }
  }

  const handleInviteClick = (invite: OrganizationInviteResponse) => {
    setSelectedInvite(invite)
    setIsDetailOpen(true)
  }

  const handleAccept = async (
    invite: OrganizationInviteResponse,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()

    const slug = invite.organization?.slug

    if (!slug) {
      toast.error("تعذر تحديد المنظمة")
      console.error("Invite organization slug is missing:", invite)
      return
    }

    setProcessingInvites((prev) => {
      const next = new Set(prev)
      next.add(invite.id)
      return next
    })

    try {
      const result = await acceptInviteAction(slug, invite.id)

      if (!result.success) {
        toast.error(result.error || "فشل قبول الدعوة")
        return
      }

      setInvites((prev) => prev.filter((i) => i.id !== invite.id))

      toast.success("تم قبول الدعوة بنجاح")

      router.refresh()
    } catch (error) {
      console.error("Accept invite failed:", error)

      toast.error(
        error instanceof Error ? error.message : "حدث خطأ أثناء قبول الدعوة"
      )
    } finally {
      setProcessingInvites((prev) => {
        const next = new Set(prev)
        next.delete(invite.id)
        return next
      })
    }
  }

  const handleDecline = async (
    invite: OrganizationInviteResponse,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()

    const slug = invite.organization?.slug

    if (!slug) {
      toast.error("تعذر تحديد المنظمة")
      console.error("Invite organization slug is missing:", invite)
      return
    }

    setProcessingInvites((prev) => {
      const next = new Set(prev)
      next.add(invite.id)
      return next
    })

    try {
      const result = await declineInviteAction(slug, invite.id)

      if (!result.success) {
        toast.error(result.error || "فشل رفض الدعوة")
        return
      }

      setInvites((prev) => prev.filter((i) => i.id !== invite.id))

      toast.success("تم رفض الدعوة")

      router.refresh()
    } catch (error) {
      console.error("Decline invite failed:", error)

      toast.error(
        error instanceof Error ? error.message : "حدث خطأ أثناء رفض الدعوة"
      )
    } finally {
      setProcessingInvites((prev) => {
        const next = new Set(prev)
        next.delete(invite.id)
        return next
      })
    }
  }
  const pendingCount = invites.length

  return (
    <div className="relative z-50">
      <button
        onClick={handleToggle}
        className={cn(
          "relative rounded-full p-2.5 text-muted-foreground transition-colors hover:bg-muted/60 hover:text-foreground focus:ring-2 focus:ring-ring focus:outline-none",
          isOpen && "bg-muted text-foreground"
        )}
      >
        <Bell className="h-5 w-5 sm:h-6 sm:w-6" />
        {pendingCount > 0 && (
          <span className="absolute end-1.5 top-1.5 flex h-4.5 w-4.5 items-center justify-center rounded-full bg-red-500 text-[11px] font-bold text-white shadow-sm ring-2 ring-background">
            {pendingCount > 9 ? "9+" : pendingCount}
          </span>
        )}
      </button>

      {isOpen && (
        <>
          <div
            className="fixed inset-0 z-40 bg-transparent"
            onClick={() => setIsOpen(false)}
          />

          <div className="absolute end-0 top-[calc(100%+0.5rem)] z-50 w-80 animate-in overflow-hidden rounded-2xl border border-border bg-background shadow-lg shadow-black/5 duration-200 zoom-in-95 fade-in slide-in-from-top-2 sm:w-96">
            <div className="flex items-center justify-between border-b border-border bg-muted/10 p-4">
              <div className="flex items-center gap-2">
                <h3 className="text-base font-semibold tracking-tight text-foreground">
                  دعوات الإنضمام
                </h3>
                {pendingCount > 0 && (
                  <span className="flex items-center rounded-full bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary">
                    {pendingCount} جديد
                  </span>
                )}
              </div>
              <button
                onClick={() => setIsOpen(false)}
                className="rounded-full p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="p-2 sm:p-3">
              {isLoading ? (
                <div className="space-y-3">
                  {[1, 2, 3].map((i) => (
                    <div
                      key={i}
                      className="flex animate-pulse flex-col gap-3 rounded-xl bg-muted/40 p-3"
                    >
                      <div className="flex items-start gap-3">
                        <div className="h-10 w-10 shrink-0 rounded-full bg-muted-foreground/10" />
                        <div className="flex-1 space-y-2">
                          <div className="h-4 w-3/4 rounded bg-muted-foreground/20"></div>
                          <div className="h-3 w-1/2 rounded bg-muted-foreground/10"></div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : invites.length > 0 ? (
                <div className="no-scrollbar flex max-h-[350px] flex-col gap-2 overflow-y-auto pb-1">
                  {invites.map((invite) => (
                    <div
                      key={invite.id}
                      onClick={() => handleInviteClick(invite)}
                      className="group flex cursor-pointer flex-col gap-3 rounded-xl border border-transparent bg-background p-3 transition-all hover:border-border hover:bg-muted/40 active:scale-[0.98] sm:p-4"
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex flex-col text-start">
                          <p className="flex items-center gap-1.5 text-sm leading-tight font-semibold text-foreground">
                            <span className="opacity-75">مِن:</span>{" "}
                            {invite.invitedByName}
                          </p>
                          {invite.organization && (
                            <p className="mt-1 flex items-center gap-1 text-xs text-muted-foreground">
                              <span>لصالح منظمة:</span>
                              <span className="font-medium text-foreground opacity-90">
                                {invite.organization.name}
                              </span>
                            </p>
                          )}
                        </div>
                        <span className="inline-flex shrink-0 items-center rounded-md bg-secondary/80 px-2 py-0.5 text-[10px] font-semibold tracking-wide text-secondary-foreground shadow-sm">
                          {invite.role === "ADMIN"
                            ? "مشرف"
                            : invite.role === "STUDENT"
                              ? "طالب"
                              : invite.role}
                        </span>
                      </div>

                      <div className="mt-1 flex items-center justify-end gap-2.5">
                        <button
                          onClick={(e) => handleAccept(invite, e)}
                          disabled={processingInvites.has(invite.id)}
                          className="inline-flex h-8 w-8 shrink-0 items-center justify-center gap-1.5 rounded-lg bg-foreground text-xs font-medium text-background transition-colors hover:bg-foreground/80 focus:ring-2 focus:ring-ring focus:ring-offset-1 disabled:cursor-not-allowed disabled:opacity-50 sm:h-9 sm:w-auto sm:px-3"
                        >
                          {processingInvites.has(invite.id) ? (
                            <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          ) : (
                            <Check className="h-4 w-4 shrink-0" />
                          )}
                          <span className="hidden sm:inline">موافقة</span>
                        </button>
                        <button
                          onClick={(e) => handleDecline(invite, e)}
                          disabled={processingInvites.has(invite.id)}
                          className="inline-flex h-8 w-8 shrink-0 items-center justify-center gap-1.5 rounded-lg border border-border bg-background text-xs font-medium text-muted-foreground transition-colors hover:border-destructive/30 hover:bg-destructive/10 hover:text-destructive focus:ring-2 focus:ring-ring focus:ring-offset-1 disabled:cursor-not-allowed disabled:opacity-50 sm:h-9 sm:w-auto sm:px-3"
                        >
                          {processingInvites.has(invite.id) ? (
                            <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          ) : (
                            <X className="h-4 w-4 shrink-0" />
                          )}
                          <span className="hidden sm:inline">رفض</span>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center px-4 py-10 text-center">
                  <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-muted/60 shadow-inner">
                    <Bell className="h-7 w-7 text-muted-foreground opacity-50" />
                  </div>
                  <h4 className="text-sm font-semibold text-foreground">
                    الاشعارات فارغة
                  </h4>
                  <p className="mt-1.5 text-xs text-muted-foreground">
                    لا توجد دعوات انضمام لديك في الوقت الحالي.
                  </p>
                </div>
              )}
            </div>
            {invites.length > 0 && (
              <div className="w-full border-t border-border bg-muted/10 px-3 py-2">
                <button
                  onClick={() => setIsOpen(false)}
                  className="flex w-full items-center justify-center gap-1 py-1.5 text-center text-xs font-medium text-muted-foreground transition-colors hover:text-foreground"
                >
                  إخفاء القائمة
                </button>
              </div>
            )}
          </div>
        </>
      )}

      <InviteDetailDialog
        invite={selectedInvite}
        isOpen={isDetailOpen}
        onClose={() => {
          setIsDetailOpen(false)
          setSelectedInvite(null)
        }}
        onAccept={(invite) =>
          setInvites((prev) => prev.filter((i) => i.id !== invite.id))
        }
        onDecline={(invite) =>
          setInvites((prev) => prev.filter((i) => i.id !== invite.id))
        }
      />
    </div>
  )
}
