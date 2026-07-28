// components/notifications.tsx
"use client"

import { useState } from "react"
import { Bell } from "lucide-react"
import { OrganizationInviteResponse } from "@/lib/api/types"
import { getMyPendingInvitesAction } from "@/lib/actions/invites"

export function Notifications() {
  const [isOpen, setIsOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])

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

  return (
    <div className="relative">
      <button
        onClick={handleToggle}
        className="relative p-2 text-gray-600 transition-colors hover:text-gray-900 focus:outline-none"
      >
        <Bell className="h-6 w-6" />
        <span className="absolute top-1 right-1 flex h-3 w-3 items-center justify-center rounded-full bg-red-500 ring-2 ring-white"></span>
      </button>

      {isOpen && (
        <div className="absolute top-full left-0 z-50 mt-2 w-80 rounded-md border border-gray-200 bg-white p-4 shadow-lg rtl:right-0 rtl:left-auto">
          <h3 className="mb-3 text-lg font-semibold text-gray-900">الدعوات</h3>

          {isLoading ? (
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="flex animate-pulse flex-col gap-2 rounded-md border p-3"
                >
                  <div className="h-4 w-3/4 rounded bg-gray-200"></div>
                  <div className="h-3 w-1/2 rounded bg-gray-100"></div>
                  <div className="mt-2 flex gap-2">
                    <div className="h-8 w-16 rounded bg-gray-200"></div>
                    <div className="h-8 w-16 rounded bg-gray-200"></div>
                  </div>
                </div>
              ))}
            </div>
          ) : invites.length > 0 ? (
            <div className="flex max-h-80 flex-col gap-3 overflow-y-auto">
              {invites.map((invite) => (
                <div
                  key={invite.id}
                  className="flex flex-col gap-2 rounded-md border p-3"
                >
                  <p className="text-sm font-medium text-gray-800">
                    دعوة من: {invite.invitedByName}
                  </p>
                  <p className="text-xs text-gray-500">الدور: {invite.role}</p>

                  <div className="mt-2 flex gap-2">
                    <button className="rounded bg-black px-3 py-1.5 text-xs font-medium text-white transition-colors hover:bg-gray-800">
                      قبول
                    </button>
                    <button className="rounded border border-gray-300 bg-white px-3 py-1.5 text-xs font-medium text-gray-700 transition-colors hover:bg-gray-50">
                      رفض
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="py-6 text-center text-sm text-gray-500">
              لا توجد دعوات حالياً
            </div>
          )}
        </div>
      )}
    </div>
  )
}
