"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { deleteComment, likeComment, unlikeComment } from "@/lib/actions/post"
import { ReactionPicker } from "@/components/posts/reaction-picker"
import type { CommentResponse } from "@/lib/api/types"
import { formatDistanceToNow } from "date-fns"
import { CornerDownLeft, Trash2 } from "lucide-react"
import { useState, useTransition } from "react"
import { ar } from "date-fns/locale"
import { toast } from "sonner"
import { ClientTimeAgo } from "../client-time-ago"

interface CommentItemProps {
  comment: CommentResponse
  onReply: (commentId: number, authorName: string) => void
  onCommentDeleted: (commentId: number) => void
}

export function CommentItem({
  comment,
  onReply,
  onCommentDeleted,
}: CommentItemProps) {
  const [isDeleting, startDelete] = useTransition()
  const [isLikePending, startLikeTransition] = useTransition()

  const [isAuthor] = useState(true)
  const [localReaction, setLocalReaction] = useState(comment.viewerReaction)
  const [localLikeCount, setLocalLikeCount] = useState(comment.likeCount || 0)

  const authorInitials =
    comment.author?.name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .slice(0, 2) ?? "؟"
  function handleDelete() {
    startDelete(async () => {
      try {
        await deleteComment(comment.id)
        onCommentDeleted(comment.id)
        toast.success("تجاوب النظام بنجاح وأتم الأمر.")
      } catch {
        toast.error("فشل إزالة التعليق بالوقت الحالي.")
      }
    })
  }

  function handleReactionSelect(type: Parameters<typeof likeComment>[1]) {
    startLikeTransition(async () => {
      try {
        if (localReaction === type) {
          await unlikeComment(comment.id)
          setLocalReaction(undefined)
          setLocalLikeCount((prev) => Math.max(0, prev - 1))
        } else {
          await likeComment(comment.id, type)
          setLocalReaction(type)
          if (!localReaction) setLocalLikeCount((prev) => prev + 1)
        }
      } catch {
        toast.error("إشكالية خفية تسببت بفشل التحديث")
      }
    })
  }

  function handleRemoveReaction() {
    startLikeTransition(async () => {
      try {
        await unlikeComment(comment.id)
        setLocalReaction(undefined)
        setLocalLikeCount((prev) => Math.max(0, prev - 1))
      } catch {
        toast.error("حدث خطأ يرجى التريث قليلاً")
      }
    })
  }

  return (
    <div className="group flex gap-3 py-3.5 transition-colors">
      <Avatar className="mt-0.5 h-9 w-9 shrink-0 border border-border/30">
        <AvatarImage src={comment.author?.picture} />
        <AvatarFallback className="bg-secondary text-[13px] font-semibold text-secondary-foreground">
          {authorInitials}
        </AvatarFallback>
      </Avatar>

      <div className="min-w-0 flex-1">
        <div className="mb-1 flex items-center gap-2">
          <span className="text-[14px] font-bold text-foreground">
            {comment.author?.name ?? "مشارك"}
          </span>
          <span className="mt-0.5 text-[12.5px] font-medium text-muted-foreground">
            {comment.baseEntity?.createdAt ? (
              <ClientTimeAgo date={comment.baseEntity.createdAt} />
            ) : null}
          </span>
        </div>

        <div className="mb-2 text-[14.5px] leading-relaxed font-medium whitespace-pre-wrap text-foreground/95">
          {comment.content}
        </div>

        <div className="flex w-full items-center gap-3">
          <div className="flex items-center gap-1.5">
            <ReactionPicker
              onReactionSelect={handleReactionSelect}
              currentReaction={localReaction}
              onRemoveReaction={handleRemoveReaction}
              size="sm"
            />

            {localLikeCount > 0 && (
              <span className="ms-1 mt-[2px] text-[13px] font-semibold text-muted-foreground">
                {localLikeCount}
              </span>
            )}
          </div>

          <Button
            variant="ghost"
            size="sm"
            className="h-7 rounded-md px-2.5 py-0 text-[13px] font-semibold text-muted-foreground hover:bg-muted/80 hover:text-foreground"
            onClick={() => onReply(comment.id, comment.author?.name ?? "مجهول")}
          >
            <CornerDownLeft className="ml-1 h-3.5 w-3.5 stroke-[2.5]" />
            رد
          </Button>

          {isAuthor && (
            <Button
              variant="ghost"
              size="sm"
              className="h-7 rounded-md px-2 py-0 text-[13px] font-semibold text-muted-foreground opacity-0 transition-opacity duration-200 group-hover:opacity-100 hover:bg-destructive/10 hover:text-destructive focus:opacity-100"
              onClick={handleDelete}
              disabled={isDeleting}
            >
              <Trash2 className="ml-1 h-3.5 w-3.5 stroke-[2]" />
              {isDeleting ? "يتم الإزالة..." : "إلغاء"}
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}
