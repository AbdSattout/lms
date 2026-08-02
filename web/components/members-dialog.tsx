// components/members-dialog.tsx
"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { OrganizationMemberResponse } from "@/lib/api/types"
import { Plus, ArrowRight } from "lucide-react"
import { getMembers } from "@/lib/actions/members"
import { AddMemberForm } from "./forms/member-form-dialog"
import { MemberDetailDialog } from "./forms/member-detial-dialog"

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
  const [selectedMember, setSelectedMember] =
    useState<OrganizationMemberResponse | null>(null)
  const [memberDetailOpen, setMemberDetailOpen] = useState(false)

  useEffect(() => {
    if (!open || !type) return
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

  const handleOpenChange = (newOpen: boolean) => {
    if (!newOpen) {
      setTimeout(() => {
        setShowAddForm(false)
        setMembers([])
      }, 200)
    }
    onOpenChange(newOpen)
  }

  const handleMemberClick = (member: OrganizationMemberResponse) => {
    setSelectedMember(member)
    setMemberDetailOpen(true)
  }

  if (!type) return null
  const title = showAddForm
    ? `إضافة ${type === "admins" ? "مشرف" : "طالب"}`
    : type === "admins"
      ? "المشرفين"
      : "الطلاب"

  return (
    <>
      <Dialog open={open} onOpenChange={handleOpenChange}>
        <DialogContent
          className="flex h-[85vh] w-full flex-col gap-0 overflow-hidden border-muted/50 p-0 shadow-lg sm:h-[600px] sm:max-w-[420px] sm:rounded-xl"
          dir="rtl"
        >
          <div className="flex h-14 shrink-0 items-center justify-between border-b bg-muted/30 p-4 pb-3">
            <div className="flex justify-start">
              {!showAddForm ? (
                <Button
                  onClick={() => setShowAddForm(true)}
                  size="sm"
                  variant="default"
                  className="h-8 gap-2"
                >
                  <Plus className="h-3 w-3" />
                  اضافة
                </Button>
              ) : (
                <Button
                  onClick={() => setShowAddForm(false)}
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 text-muted-foreground hover:text-foreground"
                >
                  <ArrowRight className="h-5 w-5" />
                </Button>
              )}
            </div>

            <DialogTitle className="flex-1 text-center text-[15px] font-bold tracking-wide">
              {title}
            </DialogTitle>
            <div className="w-[88px]"></div>
          </div>

          <div className="relative flex min-h-0 flex-1 flex-col bg-background/50">
            {showAddForm ? (
              <div className="absolute inset-0 flex h-full flex-1 flex-col">
                <AddMemberForm
                  slug={slug}
                  role={type === "admins" ? "ADMIN" : "STUDENT"}
                  onBack={() => setShowAddForm(false)}
                />
              </div>
            ) : loading ? (
              <div className="flex h-full animate-pulse items-center justify-center text-xs font-semibold text-muted-foreground">
                جاري تحميل القائمة...
              </div>
            ) : (
              <div className="custom-scrollbar h-full space-y-1 overflow-y-auto p-3">
                {members.length === 0 ? (
                  <div className="flex h-full flex-col items-center justify-center space-y-2 text-sm font-medium text-muted-foreground opacity-70">
                    <Image
                      src="/no-results.png"
                      alt="No Result"
                      width={100}
                      height={100}
                      className="block hidden opacity-40 mix-blend-luminosity grayscale invert dark:invert-0"
                    />
                    <span>لا يوجد اعضاء بعد, قم بالاضافة .</span>
                  </div>
                ) : (
                  members.map((member) => (
                    <div
                      key={member.memberId}
                      onClick={() => handleMemberClick(member)}
                      className="group flex cursor-pointer items-center gap-3 rounded-lg border-b border-muted/20 bg-background/60 p-3 transition-all duration-150 hover:bg-muted/40 hover:shadow-sm active:scale-[0.98]"
                    >
                      <Image
                        src={member.user.picture || "/default-avatar.png"}
                        alt={member.user.name || "User avatar"}
                        width={38}
                        height={38}
                        className="shrink-0 rounded-full object-cover ring-2 ring-transparent transition-all group-hover:ring-border/40"
                      />
                      <div className="flex flex-col truncate">
                        <span className="truncate text-sm font-semibold tracking-tight text-foreground">
                          {member.user.name}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>

      <MemberDetailDialog
        open={memberDetailOpen}
        onOpenChange={setMemberDetailOpen}
        member={selectedMember}
      />
    </>
  )
}
