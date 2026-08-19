"use client"

import { useEffect, useState, useTransition } from "react"
import {
  FileText,
  Mail,
  MessageSquareText,
  Phone,
  School,
  UserRound,
} from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

import type {
  CommentResponse,
  PostResponse,
  ProfileResponse,
} from "@/lib/api/types"

import {
  getAdminUserCommentsAction,
  getAdminUserPostsAction,
} from "@/lib/actions/admin"

import { ClientTimeAgo } from "@/components/client-time-ago"
import { getAdminUserAction } from "@/lib/actions/admin-moderators"
import { toast } from "sonner"
import { cn } from "@/lib/tiptap-utils"

interface UserTargetData {
  user: ProfileResponse
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
  const [isLoading, startLoading] = useTransition()

  useEffect(() => {
    startLoading(async () => {
      try {
        const [user, posts, comments] = await Promise.all([
          getAdminUserAction(userId),

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
          user,
          posts,
          comments,
        })
      } catch (error) {
        toast.error("فشل تحميل معلومات المستخدم")
      }
    })
  }, [userId])

  if (isLoading && !data) {
    return <UserTargetSkeleton />
  }

  if (!data) {
    return null
  }

  const { user, posts, comments } = data

  const profileName = user.user?.name ?? user.name ?? "مستخدم"

  const initials =
    profileName
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "؟"

  return (
    <div className="space-y-4">
      <Card className="border-border/60 shadow-sm">
        <CardContent className="p-6">
          <div className="flex items-start gap-4">
            <Avatar className="h-16 w-16 border border-border/50">
              <AvatarImage src={user.user?.picture} />

              <AvatarFallback className="bg-primary/10 text-lg font-bold text-primary">
                {initials}
              </AvatarFallback>
            </Avatar>

            <div className="min-w-0 flex-1">
              <div className="flex flex-wrap items-center gap-2">
                <h3 className="text-xl font-bold">{profileName}</h3>

                {user.user?.username && (
                  <span className="text-sm text-muted-foreground">
                    @{user.user.username}
                  </span>
                )}
              </div>

              <div className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                <ProfileField icon={Mail} value={user.email} />

                <ProfileField icon={Phone} value={user.phone} />

                <ProfileField icon={School} value={user.university} />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-3 sm:grid-cols-2">
        <StatCard
          icon={FileText}
          label="المنشورات"
          value={posts.totalElements ?? posts.content?.length ?? 0}
        />

        <StatCard
          icon={MessageSquareText}
          label="التعليقات"
          value={comments.totalElements ?? comments.content?.length ?? 0}
        />
      </div>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">آخر المنشورات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {posts.content?.length ? (
            posts.content.map((post) => (
              <div
                key={post.id}
                className="rounded-lg border border-border/50 p-4"
              >
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  {post.baseEntity?.createdAt && (
                    <ClientTimeAgo date={post.baseEntity.createdAt} />
                  )}
                </div>

                <h4 className="mt-2 font-bold">{post.title}</h4>

                {post.content && (
                  <p className="mt-1 line-clamp-2 text-sm leading-6 text-muted-foreground">
                    {post.content.replace(/[#*_`]/g, "")}
                  </p>
                )}
              </div>
            ))
          ) : (
            <EmptyState text="لا توجد منشورات" />
          )}
        </CardContent>
      </Card>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">آخر التعليقات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {comments.content?.length ? (
            comments.content.map((comment) => (
              <div
                key={comment.id}
                className="rounded-lg border border-border/50 p-4"
              >
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  {comment.baseEntity?.createdAt && (
                    <ClientTimeAgo date={comment.baseEntity.createdAt} />
                  )}
                </div>

                <p className="mt-2 text-sm leading-6">{comment.content}</p>
              </div>
            ))
          ) : (
            <EmptyState text="لا توجد تعليقات" />
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function ProfileField({
  icon: Icon,
  value,
}: {
  icon: typeof Mail
  value?: string | null
}) {
  const displayValue = value?.trim() || "غير متوفر"

  return (
    <div className="flex min-w-0 items-center gap-2 text-muted-foreground">
      <Icon className="h-4 w-4 shrink-0" />

      <span
        className={cn("truncate", !value?.trim() && "text-muted-foreground/70")}
        dir={!value?.trim() ? "rtl" : undefined}
      >
        {displayValue}
      </span>
    </div>
  )
}

function StatCard({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof FileText
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
      <Skeleton className="h-32 rounded-xl" />

      <div className="grid grid-cols-2 gap-3">
        <Skeleton className="h-20 rounded-xl" />
        <Skeleton className="h-20 rounded-xl" />
      </div>

      <Skeleton className="h-64 rounded-xl" />
      <Skeleton className="h-64 rounded-xl" />
    </div>
  )
}
