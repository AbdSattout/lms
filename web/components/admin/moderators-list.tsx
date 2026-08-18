"use client"

import { useState, useTransition } from "react"
import { Loader2, ShieldCheck, Trash2 } from "lucide-react"
import { toast } from "sonner"

import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"

import { deleteAdminModeratorAction } from "@/lib/actions/admin-moderators"

import type { AdminResponse } from "@/lib/api/types"

interface ModeratorListProps {
  moderators: AdminResponse[]
  onDeleted: (moderatorId: number) => void
}

export function ModeratorList({ moderators, onDeleted }: ModeratorListProps) {
  if (moderators.length === 0) {
    return (
      <div className="rounded-xl border border-dashed p-10 text-center">
        <ShieldCheck className="mx-auto h-9 w-9 text-muted-foreground/50" />

        <p className="mt-3 text-sm font-semibold">لا يوجد مشرفون</p>

        <p className="mt-1 text-xs text-muted-foreground">
          لم تتم إضافة أي مشرفين بعد.
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {moderators.map((moderator) => (
        <ModeratorItem
          key={moderator.id}
          moderator={moderator}
          onDeleted={onDeleted}
        />
      ))}
    </div>
  )
}

function ModeratorItem({
  moderator,
  onDeleted,
}: {
  moderator: AdminResponse
  onDeleted: (moderatorId: number) => void
}) {
  const [isDeleting, startDeleting] = useTransition()

  const initials =
    moderator.name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "M"

  function handleDelete() {
    startDeleting(async () => {
      try {
        await deleteAdminModeratorAction(moderator.id)

        toast.success("تم حذف المشرف بنجاح")
        onDeleted(moderator.id)
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "فشل حذف المشرف")
      }
    })
  }

  return (
    <Card className="border-border/60 shadow-sm">
      <CardContent className="p-4">
        <div className="flex items-center gap-3">
          <Avatar className="h-11 w-11 border border-border/50">
            <AvatarFallback className="bg-primary/10 font-bold text-primary">
              {initials}
            </AvatarFallback>
          </Avatar>

          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <p className="truncate text-sm font-bold">{moderator.name}</p>

              <Badge variant="secondary" className="rounded-full text-[10px]">
                {moderator.role === "MODERATOR" ? "مشرف" : moderator.role}
              </Badge>

              <Badge
                variant={moderator.enabled ? "outline" : "destructive"}
                className="rounded-full text-[10px]"
              >
                {moderator.enabled ? "مفعّل" : "غير مفعّل"}
              </Badge>
            </div>

            <p
              dir="ltr"
              className="mt-1 truncate text-xs text-muted-foreground"
            >
              {moderator.email}
            </p>
          </div>

          <Button
            variant="ghost"
            size="icon"
            className="shrink-0 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
            disabled={isDeleting}
            onClick={handleDelete}
          >
            {isDeleting ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Trash2 className="h-4 w-4" />
            )}

            <span className="sr-only">حذف المشرف</span>
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
