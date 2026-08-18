"use client"

import { useEffect, useState, useTransition } from "react"
import { FileText, MessageSquareText, UserRound } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

import type { CommentResponse, PostResponse } from "@/lib/api/types"

import { ClientTimeAgo } from "@/components/client-time-ago"
import {
  getAdminUserCommentsAction,
  getAdminUserPostsAction,
} from "@/lib/actions/admin"

interface UserTargetData {
  posts: {
    content: PostResponse[]
    totalElements: number
    totalPages: number
  }
  comments: {
    content: CommentResponse[]
    totalElements: number
    totalPages: number
  }
}

export function UserReportTarget({ userId }: { userId: number }) {
  const [data, setData] = useState<UserTargetData | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [isLoading, startLoading] = useTransition()

  useEffect(() => {
    startLoading(async () => {
      try {
        setError(null)

        const [posts, comments] = await Promise.all([
          getAdminUserPostsAction(userId, {
            page: 0,
            size: 6,
            sort: ["createdAt,desc"],
          }),
          getAdminUserCommentsAction(userId, {
            page: 0,
            size: 8,
            sort: ["createdAt,desc"],
          }),
        ])

        setData({
          posts,
          comments,
        })
      } catch (error) {
        setError(
          error instanceof Error ? error.message : "فشل تحميل نشاط المستخدم"
        )
      }
    })
  }, [userId])
  if (isLoading && !data) {
    return <UserTargetSkeleton />
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

  if (!data) return null

  const firstAuthor =
    data.posts.content[0]?.author ?? data.comments.content[0]?.author

  const name = firstAuthor?.name ?? `المستخدم #${userId}`
  const picture = firstAuthor?.picture

  const initials =
    name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "؟"

  return (
    <div className="space-y-4">
      <Card className="border-border/60 shadow-sm">
        <CardContent className="p-6">
          <div className="flex items-center gap-4">
            <Avatar className="h-14 w-14 border border-border/50">
              <AvatarImage src={picture} />

              <AvatarFallback className="bg-primary/10 font-bold text-primary">
                {initials}
              </AvatarFallback>
            </Avatar>

            <div>
              <h3 className="text-xl font-bold">{name}</h3>

              <p className="mt-1 text-sm text-muted-foreground">
                معرف المستخدم: #{userId}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-3 sm:grid-cols-2">
        <StatCard
          icon={FileText}
          label="المنشورات"
          value={data.posts.totalElements}
        />

        <StatCard
          icon={MessageSquareText}
          label="التعليقات"
          value={data.comments.totalElements}
        />
      </div>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">آخر المنشورات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {data.posts.content.length === 0 ? (
            <EmptyState text="لا توجد منشورات" />
          ) : (
            data.posts.content.map((post) => (
              <div
                key={post.id}
                className="rounded-lg border border-border/50 p-4"
              >
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  {post.baseEntity?.createdAt && (
                    <ClientTimeAgo date={post.baseEntity.createdAt} />
                  )}

                  <span>•</span>
                  <span>#{post.id}</span>
                </div>

                <h4 className="mt-2 font-bold">{post.title}</h4>

                {post.content && (
                  <p className="mt-1 line-clamp-2 text-sm leading-6 text-muted-foreground">
                    {post.content.replace(/[#*_`]/g, "")}
                  </p>
                )}
              </div>
            ))
          )}
        </CardContent>
      </Card>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">آخر التعليقات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {data.comments.content.length === 0 ? (
            <EmptyState text="لا توجد تعليقات" />
          ) : (
            data.comments.content.map((comment) => (
              <div
                key={comment.id}
                className="rounded-lg border border-border/50 p-4"
              >
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  {comment.baseEntity?.createdAt && (
                    <ClientTimeAgo date={comment.baseEntity.createdAt} />
                  )}

                  <span>•</span>
                  <span>#{comment.id}</span>
                </div>

                <p className="mt-2 text-sm leading-6">{comment.content}</p>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function StatCard({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof UserRound
  label: string
  value: number
}) {
  return (
    <Card className="border-border/60 shadow-sm">
      <CardContent className="p-4">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-muted">
            <Icon className="h-4 w-4 text-muted-foreground" />
          </div>

          <div>
            <p className="text-xs text-muted-foreground">{label}</p>
            <p className="mt-0.5 text-lg font-bold">{value}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

function EmptyState({ text }: { text: string }) {
  return (
    <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
      {text}
    </div>
  )
}

function UserTargetSkeleton() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-24 rounded-xl" />
      <div className="grid grid-cols-2 gap-3">
        <Skeleton className="h-20 rounded-xl" />
        <Skeleton className="h-20 rounded-xl" />
      </div>
      <Skeleton className="h-64 rounded-xl" />
      <Skeleton className="h-64 rounded-xl" />
    </div>
  )
}
