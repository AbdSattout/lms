// components/posts/comment-item.tsx
"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { deleteComment } from "@/lib/actions/post"
import type { CommentResponse } from "@/lib/api/types"
import { formatDistanceToNow } from "date-fns"
import { CornerDownLeft, Trash2 } from "lucide-react"
import { useState, useTransition } from "react"
import { ar } from "date-fns/locale"

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
  const [isAuthor] = useState(true) // TODO: Compare with current user

  const authorInitials =
    comment.author?.name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .slice(0, 2) ?? "؟"

  const timeAgo = comment.baseEntity?.createdAt
    ? formatDistanceToNow(new Date(comment.baseEntity.createdAt), {
        addSuffix: true,
        locale: ar,
      })
    : ""

  function handleDelete() {
    startDelete(async () => {
      try {
        await deleteComment(comment.id)
        onCommentDeleted(comment.id)
      } catch {
        // silently fail
      }
    })
  }

  return (
    <div className="flex gap-3 py-3">
      <Avatar className="h-8 w-8 shrink-0">
        <AvatarImage src={comment.author?.picture} />
        <AvatarFallback>{authorInitials}</AvatarFallback>
      </Avatar>
      <div className="min-w-0 flex-1">
        <div className="mb-1 flex items-center gap-2">
          <span className="text-sm font-medium">
            {comment.author?.name ?? "مستخدم"}
          </span>
          <span className="text-xs text-muted-foreground">{timeAgo}</span>
        </div>
        <p className="text-sm whitespace-pre-wrap">{comment.content}</p>
        <div className="mt-1 flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            className="h-auto py-0 text-xs text-muted-foreground hover:text-foreground"
            onClick={() =>
              onReply(comment.id, comment.author?.name ?? "مستخدم")
            }
          >
            <CornerDownLeft className="ml-1 h-3 w-3" />
            رد
          </Button>
          {isAuthor && (
            <Button
              variant="ghost"
              size="sm"
              className="h-auto py-0 text-xs text-muted-foreground hover:text-destructive"
              onClick={handleDelete}
              disabled={isDeleting}
            >
              <Trash2 className="ml-1 h-3 w-3" />
              {isDeleting ? "جاري..." : "حذف"}
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}
