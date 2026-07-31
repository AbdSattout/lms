// components/notifications.tsx
"use client"

import { useState } from "react"
import { Bell, Check, X, Loader2 } from "lucide-react"
import { OrganizationInviteResponse } from "@/lib/api/types"
import {
  getMyPendingInvitesAction,
  acceptInviteAction,
  declineInviteAction,
} from "@/lib/actions/invites"

export function Notifications() {
  const [isOpen, setIsOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])
  const [processingInvites, setProcessingInvites] = useState<Set<number>>(
    new Set()
  )

  const handleToggle = async () => {
    const willOpen = !isOpen
    setIsOpen(willOpen)

    if (willOpen) {
      setIsLoading(true)
      const data = await getMyPendingInvitesAction()
      console.log("My Invites Response:", data)
      setInvites(data)
      setIsLoading(false)
    }
  }

  const handleAccept = async (invite: OrganizationInviteResponse) => {
    if (!invite.token) {
      console.error("No token found for invite")
      return
    }

    setProcessingInvites((prev) => new Set(prev).add(invite.id))

    const result = await acceptInviteAction(invite.token)

    if (result.success) {
      setInvites((prev) => prev.filter((i) => i.id !== invite.id))
    } else {
      console.error("Failed to accept invite:", result.error)
    }

    setProcessingInvites((prev) => {
      const newSet = new Set(prev)
      newSet.delete(invite.id)
      return newSet
    })
  }

  const handleDecline = async (invite: OrganizationInviteResponse) => {
    if (!invite.token) {
      console.error("No token found for invite")
      return
    }

    setProcessingInvites((prev) => new Set(prev).add(invite.id))

    const result = await declineInviteAction(invite.token)

    if (result.success) {
      setInvites((prev) => prev.filter((i) => i.id !== invite.id))
    } else {
      console.error("Failed to decline invite:", result.error)
    }

    setProcessingInvites((prev) => {
      const newSet = new Set(prev)
      newSet.delete(invite.id)
      return newSet
    })
  }

  const pendingCount = invites.length

  return (
    <div className="relative">
      <button
        onClick={handleToggle}
        className="relative p-2 text-gray-600 transition-colors hover:text-gray-900 focus:outline-none dark:text-gray-400 dark:hover:text-gray-100"
      >
        <Bell className="h-6 w-6" />
        {pendingCount > 0 && (
          <span className="absolute top-1 right-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] font-medium text-white ring-2 ring-white dark:ring-gray-900">
            {pendingCount}
          </span>
        )}
      </button>

      {isOpen && (
        <>
          {/* Backdrop for mobile */}
          <div
            className="fixed inset-0 z-40 md:hidden"
            onClick={() => setIsOpen(false)}
          />

          {/* Notification panel - opens from left to right */}
          <div className="absolute top-full left-0 z-50 mt-2 w-80 rounded-lg border border-gray-200 bg-white shadow-xl dark:border-gray-700 dark:bg-gray-800">
            <div className="border-b border-gray-200 p-4 dark:border-gray-700">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                  الدعوات
                </h3>
                <button
                  onClick={() => setIsOpen(false)}
                  className="rounded-md p-1 text-gray-400 hover:text-gray-500 dark:hover:text-gray-300"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>
            </div>

            <div className="p-4">
              {isLoading ? (
                <div className="space-y-3">
                  {[1, 2, 3].map((i) => (
                    <div
                      key={i}
                      className="flex animate-pulse flex-col gap-2 rounded-lg border border-gray-200 p-3 dark:border-gray-700"
                    >
                      <div className="h-4 w-3/4 rounded bg-gray-200 dark:bg-gray-700"></div>
                      <div className="h-3 w-1/2 rounded bg-gray-100 dark:bg-gray-600"></div>
                      <div className="mt-2 flex gap-2">
                        <div className="h-8 w-16 rounded bg-gray-200 dark:bg-gray-700"></div>
                        <div className="h-8 w-16 rounded bg-gray-200 dark:bg-gray-700"></div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : invites.length > 0 ? (
                <div className="flex max-h-80 flex-col gap-3 overflow-y-auto">
                  {invites.map((invite) => (
                    <div
                      key={invite.id}
                      className="flex flex-col gap-2 rounded-lg border border-gray-200 p-3 transition-colors hover:border-gray-300 dark:border-gray-700 dark:hover:border-gray-600"
                    >
                      <div className="flex items-start justify-between">
                        <div>
                          <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                            دعوة من: {invite.invitedByName}
                          </p>
                          {invite.organization && (
                            <p className="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                              المنظمة: {invite.organization.name}
                            </p>
                          )}
                        </div>
                        <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs font-medium text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
                          {invite.role === "ADMIN"
                            ? "مشرف"
                            : invite.role === "STUDENT"
                              ? "طالب"
                              : invite.role}
                        </span>
                      </div>

                      <div className="mt-2 flex gap-2">
                        <button
                          onClick={() => handleAccept(invite)}
                          disabled={processingInvites.has(invite.id)}
                          className="inline-flex items-center gap-1.5 rounded-md bg-black px-3 py-1.5 text-xs font-medium text-white transition-colors hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-white dark:text-black dark:hover:bg-gray-200"
                        >
                          {processingInvites.has(invite.id) ? (
                            <Loader2 className="h-3 w-3 animate-spin" />
                          ) : (
                            <Check className="h-3 w-3" />
                          )}
                          قبول
                        </button>
                        <button
                          onClick={() => handleDecline(invite)}
                          disabled={processingInvites.has(invite.id)}
                          className="inline-flex items-center gap-1.5 rounded-md border border-gray-300 bg-white px-3 py-1.5 text-xs font-medium text-gray-700 transition-colors hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700"
                        >
                          {processingInvites.has(invite.id) ? (
                            <Loader2 className="h-3 w-3 animate-spin" />
                          ) : (
                            <X className="h-3 w-3" />
                          )}
                          رفض
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-8 text-center">
                  <Bell className="mx-auto h-8 w-8 text-gray-300 dark:text-gray-600" />
                  <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
                    لا توجد دعوات حالياً
                  </p>
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  )
}
