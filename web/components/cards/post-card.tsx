"use client"

import type { Route } from "next"
import Link from "next/link"
import Image from "next/image"
import { useState, useTransition } from "react"
import { formatDistanceToNow } from "date-fns"
import { ar } from "date-fns/locale"
import { toast } from "sonner"
import { MessageCircle, MoreHorizontal, Pencil, Trash2 } from "lucide-react"
import { ReactionPicker } from "@/components/posts/reaction-picker"

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
import { deletePost, likePost, unlikePost } from "@/lib/actions/post"

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

  const [isLikePending, startLikeTransition] = useTransition()
  const [postReaction, setPostReaction] = useState(post.viewerReaction)
  const [postLikeCount, setPostLikeCount] = useState(post.likeCount || 0)

  function handleDelete() {
    setDeleteError(null)
    startDelete(async () => {
      try {
        await deletePost(post.id, orgSlug)
        onDeleted?.(post.id)
        setDeleteOpen(false)
        toast.success("تم الحذف بنجاح")
      } catch {
        setDeleteError("فشل حذف المنشور، جرب مجددا لاحقاً.")
      }
    })
  }

  function handleReactionSelect(type: Parameters<typeof likePost>[1]) {
    startLikeTransition(async () => {
      try {
        if (postReaction === type) {
          await unlikePost(post.id)
          setPostReaction(undefined)
          setPostLikeCount((prev) => Math.max(0, prev - 1))
        } else {
          await likePost(post.id, type)
          if (!postReaction) setPostLikeCount((prev) => prev + 1)
          setPostReaction(type)
        }
      } catch {
        toast.error("فشل تنفيذ تفاعلك.")
      }
    })
  }

  function handleRemoveReaction() {
    startLikeTransition(async () => {
      try {
        await unlikePost(post.id)
        setPostReaction(undefined)
        setPostLikeCount((prev) => Math.max(0, prev - 1))
      } catch {
        toast.error("عطل فني بتحديث الحالة.")
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

  const thumbnailMatch = post.content?.match(/<img[^>]+src=["']([^"']+)["']/i)
  const thumbnail = thumbnailMatch?.[1] ?? null

  return (
    <>
      <div className="group/card relative flex flex-col rounded-xl border border-border/50 bg-card text-start text-card-foreground shadow-sm transition-colors hover:border-primary/20 hover:bg-card">
        <div className="p-4 pb-2 md:p-6 md:pb-4">
          <div className="relative z-10 mb-4 flex items-start justify-between gap-3">
            <div className="flex min-w-0 items-center gap-3">
              <Avatar className="h-10 w-10 shrink-0 border border-border/40">
                <AvatarImage src={post.author?.picture} />
                <AvatarFallback>{authorInitials}</AvatarFallback>
              </Avatar>
              <div className="flex flex-col justify-center pt-0.5 text-start">
                <span className="truncate text-[15.5px] font-bold text-foreground">
                  {post.author?.name ?? "مستخدم مجهول"}
                </span>

                <div
                  suppressHydrationWarning
                  className="mt-0.5 flex flex-wrap items-center gap-1.5 text-[12.5px] leading-none font-medium text-muted-foreground"
                >
                  <span>{timeAgo}</span>
                  {post.courseId && (
                    <>
                      <span className="mx-1 text-[10px] text-primary/40">
                        ●
                      </span>
                      <span className="rounded bg-primary/10 px-1.5 py-0.5 text-primary/80">
                        {post.title}
                      </span>
                    </>
                  )}
                </div>
              </div>
            </div>

            {isAuthor && (
              <DropdownMenu>
                <DropdownMenuTrigger className="flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-lg text-muted-foreground transition-all hover:bg-muted/80">
                  <MoreHorizontal className="h-5 w-5" />
                </DropdownMenuTrigger>
                <DropdownMenuContent
                  align="end"
                  dir="rtl"
                  className="w-40 rounded-xl p-2 shadow-lg"
                >
                  <DropdownMenuItem className="cursor-pointer">
                    <Link
                      href={`/${orgSlug}/posts/${post.id}/edit` as Route}
                      className="flex items-center gap-2 py-1 font-semibold text-foreground"
                    >
                      <Pencil className="h-4 w-4 text-primary" /> التعديل
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    className="mt-1 flex w-full cursor-pointer items-center gap-2 rounded-md py-1 font-semibold text-destructive focus:bg-destructive/10"
                    onClick={() => setDeleteOpen(true)}
                  >
                    <Trash2 className="h-4 w-4" /> تأكيد الإزالة
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>

          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="group relative mt-2 block cursor-pointer outline-none"
          >
            <h3 className="mb-2 text-[19px] leading-relaxed font-bold transition-colors group-hover:text-primary">
              {post.title}
            </h3>

            {thumbnail && (
              <div className="relative z-20 mt-3 h-56 w-full overflow-hidden rounded-xl border border-border/50 group-hover:opacity-95">
                <Image
                  src={thumbnail}
                  alt=""
                  fill
                  className="object-cover transition-transform group-hover:scale-[1.01]"
                  sizes="(max-width: 768px) 100vw, 600px"
                />
              </div>
            )}

            {post.content && (
              <div
                className="prose prose-sm dark:prose-invert mt-1 mb-4 line-clamp-3 max-w-none text-[15px] leading-[1.6] text-muted-foreground"
                dir="rtl"
                dangerouslySetInnerHTML={{ __html: post.content }}
              />
            )}
          </Link>
        </div>

        <div className="relative z-20 mt-auto flex flex-wrap items-center gap-6 rounded-b-xl border-t border-border/40 bg-muted/20 px-5 py-3 shadow-inner">
          <div className="flex items-center gap-1.5">
            <ReactionPicker
              onReactionSelect={handleReactionSelect}
              currentReaction={postReaction}
              onRemoveReaction={handleRemoveReaction}
            />
            {postLikeCount > 0 && (
              <span className="mt-[2px] text-[14px] font-bold text-muted-foreground">
                {postLikeCount}
              </span>
            )}
          </div>

          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="flex items-center gap-2 text-muted-foreground transition-all hover:text-foreground"
          >
            <MessageCircle className="h-[21px] w-[21px] stroke-[1.5px]" />
            <span className="mt-0.5 text-[14px] font-semibold">
              {post.commentCount || 0} تعليقات
            </span>
          </Link>
        </div>
      </div>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent dir="rtl" className="sm:max-w-[450px]">
          <DialogHeader>
            <DialogTitle>حذف المنشور</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من قرار التخلص من هذا المحتوى نهائياً؟
            </DialogDescription>
          </DialogHeader>
          <div className="flex justify-end gap-3 pt-3">
            <Button
              type="button"
              variant="outline"
              onClick={() => setDeleteOpen(false)}
            >
              تراجع للإلغاء
            </Button>
            <Button
              variant="destructive"
              disabled={isDeleting}
              onClick={handleDelete}
            >
              {" "}
              {isDeleting ? "الرجاء الإنتظار..." : "متابعة التنفيذ"}{" "}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
