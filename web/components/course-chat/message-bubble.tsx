"use client"

import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import {
  ContextMenu,
  ContextMenuContent,
  ContextMenuItem,
  ContextMenuSeparator,
  ContextMenuTrigger,
} from "@/components/ui/context-menu"
import type { ChatMessageResponse } from "@/lib/api/types"
import { cn } from "@/lib/utils"
import { format } from "date-fns"
import { ar } from "date-fns/locale"
import {
  Copy,
  MessageSquareOff,
  Pencil,
  Trash2,
  Volume2,
  VolumeX,
} from "lucide-react"
import { toast } from "sonner"

export function MessageBubble({
  message,
  isSent,
  muted,
  canMute,
  canDelete,
  onEdit,
  onDelete,
  onMute,
  onUnmute,
}: {
  message: ChatMessageResponse
  isSent: boolean
  muted: boolean
  canMute: boolean
  canDelete: boolean
  onEdit?: () => void
  onDelete?: () => void
  onMute?: () => void
  onUnmute?: () => void
}) {
  const isDeleted = !!message.deletedAt

  async function copyContent() {
    if (!message.content) return
    try {
      await navigator.clipboard.writeText(message.content)
      toast.success("تم نسخ الرسالة")
    } catch {
      toast.error("تعذر نسخ الرسالة")
    }
  }

  const bubble = (
    <div
      className={cn(
        "group flex w-full items-end gap-2",
        isSent ? "flex-row" : "flex-row-reverse"
      )}
    >
      {!isSent && (
        <Avatar className="size-7 shrink-0">
          <AvatarFallback className="text-xs">
            {message.senderName?.charAt(0) ?? "؟"}
          </AvatarFallback>
        </Avatar>
      )}

      <div
        className={cn(
          "relative flex max-w-[75%] flex-col gap-0.5 rounded-2xl px-3 py-2 text-sm shadow-sm",
          isSent
            ? "rounded-es-md bg-primary text-primary-foreground"
            : "rounded-ee-md bg-muted text-card-foreground dark:bg-secondary",
          isDeleted && "italic opacity-70"
        )}
      >
        {!isSent && (
          <div
            className={cn(
              "flex items-center gap-1 text-xs font-medium",
              muted && "text-destructive"
            )}
          >
            <span className="truncate">{message.senderName}</span>
            {muted && (
              <span className="inline-flex items-center gap-0.5">
                <VolumeX className="size-3" />
              </span>
            )}
          </div>
        )}

        <p className="w-full text-pretty break-words whitespace-pre-wrap">
          {isDeleted ? "تم حذف هذه الرسالة" : message.content}
        </p>

        <div
          className={cn(
            "flex items-center justify-end gap-1 text-[10px]",
            isSent ? "text-primary-foreground/70" : "text-muted-foreground"
          )}
        >
          {message.editedAt && <span>معدلة</span>}
          <span>{formatTime(message.createdAt)}</span>
        </div>
      </div>
    </div>
  )

  if (isDeleted) return bubble

  return (
    <ContextMenu>
      <ContextMenuTrigger
        className={cn(
          "w-full rounded-2xl data-popup-open:bg-accent/40 data-pressed:bg-accent/40"
        )}
      >
        {bubble}
      </ContextMenuTrigger>

      <ContextMenuContent>
        {!isDeleted && (
          <ContextMenuItem onClick={copyContent}>
            <Copy />
            نسخ
          </ContextMenuItem>
        )}
        {isSent && !isDeleted && (
          <ContextMenuItem onClick={onEdit}>
            <Pencil />
            تعديل
          </ContextMenuItem>
        )}
        {(isSent || canDelete) && !isDeleted && (
          <ContextMenuItem variant="destructive" onClick={onDelete}>
            <Trash2 />
            حذف
          </ContextMenuItem>
        )}
        {canMute && !isSent && !muted && (
          <>
            <ContextMenuSeparator />
            <ContextMenuItem variant="destructive" onClick={onMute}>
              <Volume2 />
              كتم
            </ContextMenuItem>
          </>
        )}
        {canMute && !isSent && muted && (
          <>
            <ContextMenuSeparator />
            <ContextMenuItem onClick={onUnmute}>
              <MessageSquareOff />
              رفع الكتم
            </ContextMenuItem>
          </>
        )}
      </ContextMenuContent>
    </ContextMenu>
  )
}

export function formatTime(iso: string) {
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return ""
  return format(date, "HH:mm", { locale: ar })
}

export function formatMuteRemaining(iso: string) {
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return ""
  return format(date, "dd/MM/yyyy HH:mm", { locale: ar })
}
