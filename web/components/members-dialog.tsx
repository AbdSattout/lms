// components/overview/members-dialog.tsx
"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { OrganizationMemberResponse } from "@/lib/api/types"
import { Plus, ArrowRight } from "lucide-react"
import { getMembers } from "@/lib/actions/members"
import { AddMemberForm } from "./forms/member-form-dialog"

interface MembersDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  slug: string
  type: "admins" | "students" | null
}

export function MembersDialog({
  open,
  onOpenChange,
  slug,
  type,
}: MembersDialogProps) {
  const [members, setMembers] = useState<OrganizationMemberResponse[]>([])
  const [loading, setLoading] = useState(false)
  const [showAddForm, setShowAddForm] = useState(false)

  useEffect(() => {
    if (!open || !type) return

    // Reset showAddForm when dialog opens or type changes
    setShowAddForm(false)

    const fetchMembers = async () => {
      setLoading(true)
      try {
        const data =
          type === "admins"
            ? await getMembers(slug, "admins", { page: 0, size: 50 })
            : await getMembers(slug, "students", { page: 0, size: 50 })

        setMembers(data?.content ?? [])
      } catch (error) {
        console.error("Failed to fetch members:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchMembers()
  }, [open, type, slug])

  // Reset everything when dialog closes
  const handleOpenChange = (newOpen: boolean) => {
    if (!newOpen) {
      setTimeout(() => {
        setShowAddForm(false)
        setMembers([])
      }, 200)
    }
    onOpenChange(newOpen)
  }

  if (!type) return null

  const title = showAddForm
    ? `إضافة ${type === "admins" ? "مشرف" : "طالب"}`
    : type === "admins"
      ? "المشرفين"
      : "الطلاب"

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="max-h-[80vh] overflow-y-auto" dir="rtl">
        <div className="mb-4 flex items-center justify-between">
          <div className="flex w-32 justify-start">
            {!showAddForm ? (
              <Button
                onClick={() => setShowAddForm(true)}
                size="sm"
                className="gap-2"
              >
                <Plus className="h-4 w-4" />
                اضافة عضو
              </Button>
            ) : (
              <Button
                onClick={() => setShowAddForm(false)}
                variant="ghost"
                size="icon"
                className="h-8 w-8"
              >
                <ArrowRight className="h-4 w-4" />
              </Button>
            )}
          </div>

          {/* Center Section: Dialog Title */}
          <DialogTitle className="flex-1 text-center text-lg">
            {title}
          </DialogTitle>

          {/* Left Section (Empty spacer to keep the title perfectly centered) */}
          <div className="w-32"></div>
        </div>

        {showAddForm ? (
          <AddMemberForm
            slug={slug}
            role={type === "admins" ? "ADMIN" : "STUDENT"}
            onBack={() => setShowAddForm(false)}
          />
        ) : loading ? (
          <div className="py-8 text-center text-muted-foreground">
            جاري التحميل...
          </div>
        ) : (
          <div className="space-y-2">
            {members.length === 0 ? (
              <div className="py-8 text-center text-muted-foreground">
                لا يوجد {type === "admins" ? "مشرفين" : "طلاب"} حالياً
              </div>
            ) : (
              members.map((member) => (
                <div
                  key={member.memberId}
                  className="flex items-center gap-3 rounded-lg p-2 hover:bg-muted"
                >
                  <Image
                    src={member.user.picture || "/default-avatar.png"}
                    alt={member.user.name || "User avatar"}
                    width={40}
                    height={40}
                    className="rounded-full"
                  />
                  <span>{member.user.name}</span>
                </div>
              ))
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
