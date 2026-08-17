"use client"

import { useState } from "react"
import { Bell, Check, Loader2, UserRound, X } from "lucide-react"
import { toast } from "sonner"

import type { JoinRequestResponse } from "@/lib/api/types"

import { usePendingJoinRequests } from "@/hooks/use-pending-join-requests"
import { cn } from "@/lib/utils"
import Image from "next/image"
import {
  acceptJoinRequestAction,
  rejectJoinRequestAction,
} from "@/lib/actions/join-request"

interface JoinRequestsNotificationProps {
  slug: string
}

export function JoinRequestsNotification({
  slug,
}: JoinRequestsNotificationProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [processingRequests, setProcessingRequests] = useState<Set<number>>(
    new Set()
  )

  const {
    data: requests = [],
    isLoading,
    mutate,
  } = usePendingJoinRequests(slug)

  const pendingCount = requests.length

  const handleToggle = () => {
    setIsOpen((prev) => !prev)
  }

  const setProcessing = (id: number, processing: boolean) => {
    setProcessingRequests((prev) => {
      const next = new Set(prev)

      if (processing) {
        next.add(id)
      } else {
        next.delete(id)
      }

      return next
    })
  }

  const handleAccept = async (
    request: JoinRequestResponse,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()

    setProcessing(request.id, true)

    try {
      const result = await acceptJoinRequestAction(slug, request.id)

      if (!result.success) {
        toast.error(result.error || "فشل قبول طلب الانضمام")
        return
      }

      toast.success("تم قبول طلب الانضمام بنجاح")

      await mutate()
    } catch (error) {
      console.error("Accept join request failed:", error)

      toast.error(
        error instanceof Error
          ? error.message
          : "حدث خطأ أثناء قبول طلب الانضمام"
      )
    } finally {
      setProcessing(request.id, false)
    }
  }

  const handleReject = async (
    request: JoinRequestResponse,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()

    setProcessing(request.id, true)

    try {
      const result = await rejectJoinRequestAction(slug, request.id)

      if (!result.success) {
        toast.error(result.error || "فشل رفض طلب الانضمام")
        return
      }

      toast.success("تم رفض طلب الانضمام")

      await mutate()
    } catch (error) {
      console.error("Reject join request failed:", error)

      toast.error(
        error instanceof Error
          ? error.message
          : "حدث خطأ أثناء رفض طلب الانضمام"
      )
    } finally {
      setProcessing(request.id, false)
    }
  }

  return (
    <div className="relative z-50 ml-5">
      <button
        type="button"
        onClick={handleToggle}
        aria-label="طلبات الانضمام"
        className={cn(
          "relative rounded-full p-2.5 text-muted-foreground transition-colors",
          "hover:bg-muted/60 hover:text-foreground",
          "focus:ring-2 focus:ring-ring focus:outline-none",
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

          <div className="absolute top-[calc(100%+0.5rem)] left-0 z-50 w-80 overflow-hidden rounded-2xl border border-border bg-background shadow-lg sm:w-96">
            <div className="flex items-center justify-between border-b border-border bg-muted/10 p-4">
              <div className="flex items-center gap-2">
                <h3 className="text-base font-semibold text-foreground">
                  طلبات الانضمام
                </h3>

                {pendingCount > 0 && (
                  <span className="rounded-full bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary">
                    {pendingCount} جديد
                  </span>
                )}
              </div>

              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="rounded-full p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="p-2 sm:p-3">
              {isLoading ? (
                <div className="space-y-3">
                  {[1, 2, 3].map((item) => (
                    <div
                      key={item}
                      className="animate-pulse rounded-xl bg-muted/40 p-4"
                    >
                      <div className="flex gap-3">
                        <div className="h-10 w-10 rounded-full bg-muted-foreground/10" />

                        <div className="flex-1 space-y-2">
                          <div className="h-4 w-3/4 rounded bg-muted-foreground/20" />
                          <div className="h-3 w-1/2 rounded bg-muted-foreground/10" />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : requests.length > 0 ? (
                <div className="no-scrollbar flex max-h-[350px] flex-col gap-2 overflow-y-auto pb-1">
                  {requests.map((request) => {
                    const isProcessing = processingRequests.has(request.id)

                    return (
                      <div
                        key={request.id}
                        className="rounded-xl border border-transparent bg-background p-3 transition-colors hover:border-border hover:bg-muted/40 sm:p-4"
                      >
                        <div className="flex items-start gap-3">
                          <div className="flex h-10 w-10 shrink-0 items-center justify-center overflow-hidden rounded-full bg-muted">
                            {request.user.picture ? (
                              <Image
                                src={request.user.picture}
                                alt={request.user.name ?? "User"}
                                className="h-full w-full object-cover"
                              />
                            ) : (
                              <UserRound className="h-5 w-5 text-muted-foreground" />
                            )}
                          </div>

                          <div className="min-w-0 flex-1">
                            <p className="truncate text-sm font-semibold text-foreground">
                              {request.user.name}
                            </p>

                            <p className="mt-1 text-xs text-muted-foreground">
                              يريد الانضمام إلى المنظمة
                            </p>

                            <p className="mt-1 text-[11px] text-muted-foreground">
                              {new Date(request.createdAt).toLocaleString("ar")}
                            </p>
                          </div>
                        </div>

                        <div className="mt-3 flex justify-end gap-2">
                          <button
                            type="button"
                            onClick={(e) => handleAccept(request, e)}
                            disabled={isProcessing}
                            className="inline-flex h-8 items-center justify-center gap-1.5 rounded-lg bg-foreground px-3 text-xs font-medium text-background transition-colors hover:bg-foreground/80 disabled:cursor-not-allowed disabled:opacity-50"
                          >
                            {isProcessing ? (
                              <Loader2 className="h-3.5 w-3.5 animate-spin" />
                            ) : (
                              <Check className="h-3.5 w-3.5" />
                            )}
                            موافقة
                          </button>

                          <button
                            type="button"
                            onClick={(e) => handleReject(request, e)}
                            disabled={isProcessing}
                            className="inline-flex h-8 items-center justify-center gap-1.5 rounded-lg border border-border bg-background px-3 text-xs font-medium text-muted-foreground transition-colors hover:border-destructive/30 hover:bg-destructive/10 hover:text-destructive disabled:cursor-not-allowed disabled:opacity-50"
                          >
                            {isProcessing ? (
                              <Loader2 className="h-3.5 w-3.5 animate-spin" />
                            ) : (
                              <X className="h-3.5 w-3.5" />
                            )}
                            رفض
                          </button>
                        </div>
                      </div>
                    )
                  })}
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center px-4 py-10 text-center">
                  <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-muted/60">
                    <Bell className="h-7 w-7 text-muted-foreground opacity-50" />
                  </div>

                  <h4 className="text-sm font-semibold text-foreground">
                    لا توجد طلبات
                  </h4>

                  <p className="mt-1.5 text-xs text-muted-foreground">
                    لا توجد طلبات انضمام معلقة حالياً.
                  </p>
                </div>
              )}
            </div>

            {requests.length > 0 && (
              <div className="border-t border-border bg-muted/10 px-3 py-2">
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="flex w-full justify-center py-1.5 text-xs font-medium text-muted-foreground transition-colors hover:text-foreground"
                >
                  إخفاء القائمة
                </button>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  )
}
