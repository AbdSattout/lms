"use client"

import { useEffect, useState, useTransition } from "react"
import { FileText, MessageCircle } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

import type { PostResponse } from "@/lib/api/types"

import { TiptapRenderer } from "@/components/editor/renderer"
import { ClientTimeAgo } from "@/components/client-time-ago"
import { getAdminOrganizationPostAction } from "@/lib/actions/admin"
import { toast } from "sonner"

export function PostReportTarget({
  organizationId,
  postId,
}: {
  organizationId: number
  postId: number
}) {
  const [post, setPost] = useState<PostResponse | null>(null)
  const [isLoading, startLoading] = useTransition()

  useEffect(() => {
    startLoading(async () => {
      try {
        const result = await getAdminOrganizationPostAction(
          organizationId,
          postId
        )

        setPost(result)
      } catch (error) {
        toast.error("فشل تحميل المنشور")
      }
    })
  }, [organizationId, postId])

  if (isLoading && !post) {
    return <PostTargetSkeleton />
  }

  if (!post) return null

  const name = post.author?.name ?? "مستخدم مجهول"

  const initials =
    name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "؟"

  return (
    <Card className="overflow-hidden border-border/60 shadow-sm">
      <CardHeader className="border-b border-border/50">
        <div className="flex items-center gap-2">
          <FileText className="h-4 w-4 text-primary" />

          <CardTitle className="text-base">المنشور المبلغ عنه</CardTitle>
        </div>
      </CardHeader>

      <CardContent className="p-5 md:p-6">
        <div className="flex items-center gap-3">
          <Avatar className="h-10 w-10 border border-border/40">
            <AvatarImage src={post.author?.picture} />

            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>

          <div className="min-w-0">
            <p className="truncate text-[15px] font-bold">{name}</p>

            <div className="mt-0.5 text-xs text-muted-foreground">
              {post.baseEntity?.createdAt ? (
                <ClientTimeAgo date={post.baseEntity.createdAt} />
              ) : null}
            </div>
          </div>
        </div>

        <div className="mt-5">
          <h2 className="text-xl font-bold">{post.title}</h2>

          {post.content && (
            <TiptapRenderer
              content={post.content}
              className="prose prose-neutral dark:prose-invert mt-4 max-w-none text-[15px] leading-relaxed"
            />
          )}
        </div>

        <div className="mt-5 flex items-center gap-6 border-t border-border/50 pt-4 text-sm text-muted-foreground">
          <span>{post.likeCount} إعجاب</span>

          <span className="flex items-center gap-1.5">
            <MessageCircle className="h-4 w-4" />
            {post.commentCount} تعليق
          </span>
        </div>
      </CardContent>
    </Card>
  )
}

function PostTargetSkeleton() {
  return (
    <Card>
      <CardContent className="space-y-4 p-6">
        <div className="flex items-center gap-3">
          <Skeleton className="h-10 w-10 rounded-full" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-32" />
            <Skeleton className="h-3 w-20" />
          </div>
        </div>

        <Skeleton className="h-7 w-2/3" />
        <Skeleton className="h-32 w-full rounded-lg" />
      </CardContent>
    </Card>
  )
}
