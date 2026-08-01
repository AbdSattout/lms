"use client"

import type { Route } from "next"
import Link from "next/link"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { CommentSection } from "@/components/posts/comment-section"
import type { CommentResponse, PostResponse } from "@/lib/api/types"
import { formatDistanceToNow } from "date-fns"
import { ar } from "date-fns/locale"
import { MessageCircle, MoreHorizontal, Pencil, Trash2, X } from "lucide-react"
import { ReactionPicker } from "@/components/posts/reaction-picker"
import {
  likePost,
  unlikePost,
  createComment,
  deletePost,
} from "@/lib/actions/post"
import { useState, useTransition } from "react"
import { toast } from "sonner"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { useRouter } from "next/navigation"

interface PostDetailProps {
  post: PostResponse
  comments: CommentResponse[]
  orgSlug: string
}

export function PostDetail({
  post,
  comments: initialComments,
  orgSlug,
}: PostDetailProps) {
  const router = useRouter()
  const [comments, setComments] = useState<CommentResponse[]>(initialComments)
  const [newComment, setNewComment] = useState("")
  const [isSubmitting, startSubmit] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const [isLikePending, startLikeTransition] = useTransition()
  const [replyingTo, setReplyingTo] = useState<{
    id: number
    authorName: string
  } | null>(null)

  const [isAuthor] = useState(true)
  const [postReaction, setPostReaction] = useState(post.viewerReaction)
  const [postLikeCount, setPostLikeCount] = useState(post.likeCount || 0)

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

  function handleSubmitComment() {
    if (!newComment.trim()) return

    setError(null)
    startSubmit(async () => {
      try {
        const comment = await createComment(post.id, {
          content: newComment.trim(),
          parentCommentId: replyingTo?.id ?? null,
        })
        setComments((prev) => [...prev, comment])
        setNewComment("")
        setReplyingTo(null)
        toast.success("تم إضافة التعليق بنجاح")
      } catch {
        setError("فشل إضافة التعليق. يرجى المحاولة مرة أخرى.")
      }
    })
  }

  function handleReply(commentId: number, authorName: string) {
    setReplyingTo({ id: commentId, authorName })
    setNewComment("")
    setTimeout(() => {
      document.getElementById("comment-textarea")?.focus()
      document
        .getElementById("comment-textarea")
        ?.scrollIntoView({ behavior: "smooth", block: "center" })
    }, 150)
  }

  async function handleDeletePost() {
    if (confirm("هل أنت متأكد من حذف المنشور نهائياً؟")) {
      try {
        await deletePost(post.id, orgSlug)
        toast.success("تم حذف المنشور")
        router.push(`/${orgSlug}/posts` as Route)
      } catch {
        toast.error("حدث خطأ أثناء الحذف")
      }
    }
  }

  function handlePostReaction(type: Parameters<typeof likePost>[1]) {
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
        toast.error("فشل تحديث التفاعل")
      }
    })
  }

  function handleRemovePostReaction() {
    startLikeTransition(async () => {
      try {
        await unlikePost(post.id)
        setPostReaction(undefined)
        setPostLikeCount((prev) => Math.max(0, prev - 1))
      } catch {
        toast.error("فشل إزالة التفاعل")
      }
    })
  }

  return (
    <div className="mx-auto flex w-full max-w-[850px] flex-col gap-6 pt-2 pb-20 text-start">
      <div className="rounded-xl border border-border/50 bg-card p-5 text-card-foreground shadow-sm transition-all md:p-7">
        <div className="mb-6 flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10 shrink-0 shadow-sm ring-1 ring-border/40">
              <AvatarImage src={post.author?.picture} />
              <AvatarFallback>{authorInitials}</AvatarFallback>
            </Avatar>
            <div className="flex flex-col gap-1 text-start">
              <span className="truncate text-base font-bold text-foreground">
                {post.author?.name ?? "مستخدم"}
              </span>
              <div className="flex items-center gap-2 text-[13px] leading-none font-medium text-muted-foreground">
                <span suppressHydrationWarning>{timeAgo}</span>
                {post.courseId && (
                  <>
                    <span className="text-[10px]">●</span>
                    <span className="rounded-md bg-primary/10 px-2 py-0.5 text-[11px] font-bold text-primary/90">
                      دورة #{post.title}
                    </span>
                  </>
                )}
              </div>
            </div>
          </div>

          {isAuthor && (
            <DropdownMenu>
              <DropdownMenuTrigger className="flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground">
                <MoreHorizontal className="h-5 w-5" />
              </DropdownMenuTrigger>
              <DropdownMenuContent
                align="end"
                dir="rtl"
                className="w-36 shadow-lg"
              >
                <DropdownMenuItem className="cursor-pointer gap-2 py-2">
                  <Link
                    href={`/${orgSlug}/posts/${post.id}/edit` as Route}
                    className="flex w-full items-center gap-2"
                  >
                    <Pencil className="h-4 w-4" /> تعديل
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="cursor-pointer gap-2 py-2 text-destructive focus:bg-destructive/10 focus:text-destructive"
                  onClick={handleDeletePost}
                >
                  <Trash2 className="h-4 w-4" /> حذف
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>

        <div className="pb-5">
          <h1 className="mb-4 text-2xl leading-tight font-bold">
            {post.title}
          </h1>
          {post.content && (
            <div
              className="prose prose-neutral dark:prose-invert max-w-none text-[15.5px] leading-relaxed whitespace-pre-wrap"
              dir="rtl"
              dangerouslySetInnerHTML={{ __html: post.content }}
            />
          )}
        </div>

        <div className="flex flex-wrap items-center justify-between border-t border-border/50 px-2 pt-4">
          <div className="flex w-full items-center gap-6">
            <div className="flex items-center gap-1.5 transition-transform">
              <ReactionPicker
                onReactionSelect={handlePostReaction}
                currentReaction={postReaction}
                onRemoveReaction={handleRemovePostReaction}
              />
              {postLikeCount > 0 && (
                <span className="me-1 mt-[2px] text-[15px] font-bold text-muted-foreground">
                  {postLikeCount}
                </span>
              )}
            </div>

            <button
              onClick={() =>
                document.getElementById("comment-textarea")?.focus()
              }
              className="flex cursor-pointer items-center gap-1.5 text-muted-foreground transition-colors hover:text-foreground"
            >
              <MessageCircle className="h-6 w-6 stroke-[1.5]" />
              <span className="mt-1 text-[14.5px] font-bold">
                {post.commentCount} تعليق
              </span>
            </button>
          </div>
        </div>
      </div>

      <div className="mt-3 rounded-xl border border-border/50 bg-card p-5 shadow-sm">
        {replyingTo && (
          <div className="mb-4 flex items-center justify-between rounded-lg border border-primary/10 bg-primary/5 px-4 py-3">
            <span className="text-[13px] font-semibold text-primary">
              الرد على تعليق: @{replyingTo.authorName}
            </span>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setReplyingTo(null)}
              className="h-7 text-muted-foreground hover:bg-muted"
            >
              إلغاء الرد <X className="mr-2 h-4 w-4" />
            </Button>
          </div>
        )}

        {error && (
          <p className="mb-4 rounded-md border border-destructive/20 bg-destructive/10 p-3 text-center text-sm font-medium text-destructive">
            {error}
          </p>
        )}

        <div className="group relative">
          <Textarea
            id="comment-textarea"
            placeholder={
              replyingTo
                ? "اكتب ردك بشكل محترم ومُثرٍ للنقاش..."
                : "أضف تعليقاً وشارك أفكارك البناءة مع الجميع..."
            }
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            className="min-h-24 resize-y rounded-lg border-border/60 bg-transparent p-4 text-[14.5px] shadow-inner transition-all placeholder:text-muted-foreground focus:bg-background"
            dir="rtl"
          />
          <div className="mt-4 flex justify-end">
            <Button
              onClick={handleSubmitComment}
              disabled={isSubmitting || !newComment.trim()}
              className="px-8 font-semibold tracking-wide shadow"
            >
              {isSubmitting
                ? "جاري الإرسال..."
                : replyingTo
                  ? "تأكيد الرد"
                  : "إضافة التعليق"}
            </Button>
          </div>
        </div>
      </div>

      <div className="mt-2 bg-transparent">
        <CommentSection
          comments={comments}
          onReply={handleReply}
          onCommentDeleted={(commentId) =>
            setComments((prev) => prev.filter((c) => c.id !== commentId))
          }
        />
      </div>
    </div>
  )
}
