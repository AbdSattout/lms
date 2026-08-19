"use client"

import { useEffect, useState, useTransition } from "react"
import { MessageSquareText, UserRound } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

import type { CommentResponse } from "@/lib/api/types"
import { getAdminCommentAction } from "@/lib/actions/admin"
import { ClientTimeAgo } from "@/components/client-time-ago"

interface CommentReportTargetProps {
  commentId: number
}

export function CommentReportTarget({ commentId }: CommentReportTargetProps) {
  const [comment, setComment] = useState<CommentResponse | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [isLoading, startLoading] = useTransition()

  useEffect(() => {
    startLoading(async () => {
      try {
        setError(null)

        const result = await getAdminCommentAction(commentId)

        setComment(result)
      } catch (error) {
        setError(error instanceof Error ? error.message : "فشل تحميل التعليق")
      }
    })
  }, [commentId])

  if (isLoading && !comment) {
    return <CommentTargetSkeleton />
  }

  if (error) {
    return (
      <Card>
        <CardContent className="p-6 text-center text-sm text-destructive">
          {error}
        </CardContent>
      </Card>
    )
  }

  if (!comment) {
    return null
  }

  const authorName = comment.author?.name ?? "مستخدم مجهول"

  const authorInitials =
    authorName
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "؟"

  return (
    <Card className="border-border/60 bg-card shadow-sm">
      <CardHeader className="border-b border-border/50">
        <div className="flex items-center gap-2">
          <MessageSquareText className="h-4 w-4 text-primary" />

          <CardTitle className="text-base">التعليق المبلغ عنه</CardTitle>
        </div>
      </CardHeader>

      <CardContent className="p-5 md:p-6">
        <div className="flex gap-3">
          <Avatar className="mt-0.5 h-10 w-10 shrink-0 border border-border/40">
            <AvatarImage src={comment.author?.picture} />
            <AvatarFallback className="bg-secondary text-sm font-semibold text-secondary-foreground">
              {authorInitials}
            </AvatarFallback>
          </Avatar>

          <div className="min-w-0 flex-1">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="text-[15px] font-bold text-foreground">
                {authorName}
              </span>

              {comment.baseEntity?.createdAt && (
                <span className="text-[12px] font-medium text-muted-foreground">
                  <ClientTimeAgo date={comment.baseEntity.createdAt} />
                </span>
              )}
            </div>

            <div className="rounded-lg border border-border/40 bg-muted/30 px-4 py-3">
              <p className="text-[14.5px] leading-relaxed font-medium whitespace-pre-wrap text-foreground/95">
                {comment.content}
              </p>
            </div>

            <div className="mt-3 flex items-center gap-3 text-xs text-muted-foreground">
              <span className="flex items-center gap-1.5">
                <UserRound className="h-3.5 w-3.5" />
                {comment.author?.name ?? "مستخدم"}
              </span>

              {comment.likeCount > 0 && (
                <>
                  <span>•</span>
                  <span>{comment.likeCount} إعجاب</span>
                </>
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

function CommentTargetSkeleton() {
  return (
    <Card className="border-border/60 shadow-sm">
      <CardHeader>
        <Skeleton className="h-5 w-40" />
      </CardHeader>

      <CardContent className="p-5 md:p-6">
        <div className="flex gap-3">
          <Skeleton className="h-10 w-10 shrink-0 rounded-full" />

          <div className="flex-1 space-y-3">
            <Skeleton className="h-4 w-32" />
            <Skeleton className="h-20 w-full rounded-lg" />
            <Skeleton className="h-3 w-24" />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
