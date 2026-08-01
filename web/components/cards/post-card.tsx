"use client"

import type { Route } from "next"
import Link from "next/link"
import Image from "next/image"
import { useState, useTransition } from "react"
import { formatDistanceToNow } from "date-fns"
import { ar } from "date-fns/locale"
import {
  Heart,
  MessageCircle,
  MoreHorizontal,
  Pencil,
  Trash2,
} from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { PostResponse } from "@/lib/api/types"
import { deletePost } from "@/lib/actions/post"

interface PostCardProps {
  post: PostResponse
  orgSlug: string
  onDeleted?: (postId: number) => void
}

export function PostCard({ post, orgSlug, onDeleted }: PostCardProps) {
  const [deleteOpen, setDeleteOpen] = useState(false)
  const [isDeleting, startDelete] = useTransition()
  const [deleteError, setDeleteError] = useState<string | null>(null)
  const [isAuthor] = useState(true)

  function handleDelete() {
    setDeleteError(null)
    startDelete(async () => {
      try {
        await deletePost(post.id, orgSlug)
        onDeleted?.(post.id)
        setDeleteOpen(false)
      } catch {
        setDeleteError("فشل حذف المنشور")
      }
    })
  }

  const authorInitials =
    post.author?.name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .slice(0, 2) ?? "؟"

  const timeAgo = post.baseEntity?.createdAt
    ? formatDistanceToNow(new Date(post.baseEntity.createdAt), {
        addSuffix: true,
        locale: ar,
      })
    : ""

  // ✅ 1. UPDATE: Fetch image URL from HTML (using <img src="..." > structure) instead of Markdown
  const thumbnailMatch = post.content?.match(/<img[^>]+src=["']([^"']+)["']/i)
  const thumbnail = thumbnailMatch?.[1] ?? null

  return (
    <>
      <div className="group/card relative flex flex-col rounded-xl border border-border/40 bg-card text-start text-card-foreground shadow-sm transition-colors hover:bg-muted/40">
        <div className="p-4 md:p-5">
          <div className="relative z-10 mb-5 flex items-start justify-between gap-3">
            <div className="flex min-w-0 items-center gap-3">
              <Avatar className="h-10 w-10 shrink-0 ring-1 ring-border/40">
                <AvatarImage src={post.author?.picture} />
                <AvatarFallback>{authorInitials}</AvatarFallback>
              </Avatar>
              <div className="flex flex-col gap-0.5 text-start">
                <span className="truncate text-[15px] font-bold text-foreground">
                  {post.author?.name ?? "مستخدم"}
                </span>

                <div className="flex flex-wrap items-center gap-2 text-[13px] font-medium text-muted-foreground">
                  <span>{timeAgo}</span>
                  {post.courseId && (
                    <>
                      <span className="text-[10px]">●</span>
                      <span className="rounded bg-primary/10 px-1.5 py-0.5 text-xs font-semibold text-primary/90">
                        دورة #{post.title}
                      </span>
                    </>
                  )}
                </div>
              </div>
            </div>

            {isAuthor && (
              <DropdownMenu>
                <DropdownMenuTrigger className="flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-black/10 hover:text-foreground">
                  <MoreHorizontal className="h-5 w-5" />
                </DropdownMenuTrigger>
                <DropdownMenuContent
                  align="end"
                  dir="rtl"
                  className="w-auto min-w-0"
                >
                  <DropdownMenuItem className="cursor-pointer p-0">
                    <Link
                      href={`/${orgSlug}/posts/${post.id}/edit` as Route}
                      className="flex w-full items-center justify-center gap-2 px-4 py-2"
                    >
                      <Pencil className="h-4 w-4" />
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    className="flex w-full cursor-pointer items-center justify-center gap-2 px-4 py-2 text-destructive focus:bg-destructive/10 focus:text-destructive"
                    onClick={() => setDeleteOpen(true)}
                  >
                    <Trash2 className="h-4 w-4" />
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>

          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="group block cursor-pointer outline-none before:absolute before:inset-0 before:z-0"
          >
            <h3 className="mb-3 text-xl leading-relaxed font-extrabold transition-colors group-hover:text-primary">
              {post.title}
            </h3>

            {thumbnail && (
              <div className="relative z-20 mb-3 h-52 w-full overflow-hidden rounded-xl border border-border/40">
                <Image
                  src={thumbnail}
                  alt=""
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 100vw, 600px"
                />
              </div>
            )}

            {/* ✅ 2. UPDATE: Added correctly mapped HTML to preserve colors and boldness  */}
            {post.content && (
              <div
                className="prose prose-sm dark:prose-invert line-clamp-3 max-w-none overflow-hidden text-[15px] leading-relaxed text-muted-foreground"
                dir="rtl"
                dangerouslySetInnerHTML={{
                  __html: post.content,
                }}
              />
            )}
          </Link>
        </div>

        <div className="relative z-10 mt-auto flex items-center gap-6 border-t border-border/40 px-4 py-3 md:px-5">
          <button className="flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-red-500">
            <Heart className="h-5 w-5" />
            <span className="text-[15px] font-bold">{post.likeCount || 0}</span>
          </button>

          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="z-20 flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-primary"
          >
            <MessageCircle className="h-5 w-5" />
            <span className="text-[15px] font-bold">
              {post.commentCount || 0} تعليق
            </span>
          </Link>
        </div>
      </div>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>حذف المنشور</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.
            </DialogDescription>
          </DialogHeader>
          {deleteError && (
            <p className="text-sm font-medium text-destructive">
              {deleteError}
            </p>
          )}
          <div className="flex justify-end gap-3 pt-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => setDeleteOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              disabled={isDeleting}
              onClick={handleDelete}
            >
              {isDeleting ? "جاري الحذف..." : "تأكيد الحذف"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
