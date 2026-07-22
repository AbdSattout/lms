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
import {
  Heart,
  MessageCircle,
  MoreHorizontal,
  Pencil,
  Trash2,
  X,
} from "lucide-react"
import { useState, useTransition } from "react"
import { toast } from "sonner"
import { createComment, deletePost } from "@/lib/actions/post"
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
  const [replyingTo, setReplyingTo] = useState<{
    id: number
    authorName: string
  } | null>(null)

  // حالة التحكم بالـ Dropdown للكاتب (يمكن ربطها بالمستخدم الفعلي لاحقاً)
  const [isAuthor] = useState(true)

  const authorInitials =
    post.author?.name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .slice(0, 2) ?? "؟"

  // تطبيق الترجمة العربية للوقت (مثال: منذ ساعتين)
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
    // وضع الفوكس بسلاسة بعد الضغط على "رد"
    setTimeout(() => document.getElementById("comment-textarea")?.focus(), 50)
  }

  async function handleDeletePost() {
    if (confirm("هل أنت متأكد من حذف المنشور نهائياً؟")) {
      try {
        await deletePost(post.id, orgSlug)
        toast.success("تم حذف المنشور")
        router.push(`/${orgSlug}/posts` as Route)
      } catch (err) {
        toast.error("حدث خطأ أثناء الحذف")
      }
    }
  }

  return (
    // مركزنا محتوى التفاصيل في عرض مريح مع هوامش جذابة Text-start لمعالجة RTL بشكل مثالي
    <div className="mx-auto flex w-full max-w-[720px] flex-col gap-7 pt-2 pb-20 text-start">
      {/* 1. قسم تفاصيل المنشور بالاستايل المتوافق 100% مع PostCard */}
      <div className="rounded-xl border border-border/50 bg-card p-5 text-card-foreground shadow-sm md:p-7">
        {/* هيدر الكارد: معلومات المستخدم والقائمة المنسدلة */}
        <div className="mb-5 flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10 shrink-0 ring-1 ring-border/40">
              <AvatarImage src={post.author?.picture} />
              <AvatarFallback>{authorInitials}</AvatarFallback>
            </Avatar>
            <div className="flex flex-col gap-0.5 text-start">
              <span className="truncate text-[15px] font-bold text-foreground">
                {post.author?.name ?? "مستخدم"}
              </span>
              <div className="flex items-center gap-2 text-[13px] font-medium text-muted-foreground">
                <span>{timeAgo}</span>
                {post.courseId && (
                  <>
                    <span className="text-[10px]">●</span>
                    <span className="rounded bg-primary/10 px-1.5 py-0.5 text-xs font-semibold text-primary/90">
                      دورة #{post.courseId}
                    </span>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* القائمة الجانبية للتعديل والحذف (مثل ما في بوست كارد تماما) */}
          {isAuthor && (
            <DropdownMenu>
              <DropdownMenuTrigger className="flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-black/10 hover:text-foreground">
                <MoreHorizontal className="h-5 w-5" />
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" dir="rtl" className="w-36">
                <DropdownMenuItem className="cursor-pointer gap-2 py-2">
                  <Link href={`/${orgSlug}/posts/${post.id}/edit` as Route}>
                    <Pencil className="h-4 w-4" /> تعديل المنشور
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="cursor-pointer gap-2 py-2 text-red-500 focus:bg-red-500/10 focus:text-red-500"
                  onClick={handleDeletePost}
                >
                  <Trash2 className="h-4 w-4" /> حذف المنشور
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>

        {/* محتوى المنشور (نص Markdown مع العنوان) */}
        <div className="border-b border-border/40 pb-6">
          <h1 className="mb-4 text-xl leading-relaxed font-extrabold">
            {post.title}
          </h1>
          {post.content && (
            <div
              className="prose prose-neutral dark:prose-invert max-w-none text-[15.5px] leading-relaxed whitespace-pre-wrap"
              dir="rtl"
              dangerouslySetInnerHTML={{
                __html: post.content, // Editor Output Content (html أو غيره)
              }}
            />
          )}
        </div>

        {/* إحصائيات التفاعل الخاصة بالتفاصيل (استخدمنا comments.length للموثوقية الأكبر) */}
        <div className="mt-5 flex items-center gap-6 px-1">
          <button className="flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-red-500">
            <Heart className="h-6 w-6" />
            <span className="text-[15px] font-bold">{post.likeCount || 0}</span>
          </button>
          <div className="flex cursor-pointer items-center gap-1.5 text-muted-foreground transition-colors hover:text-primary">
            <MessageCircle className="h-6 w-6" />
            <span className="text-[15px] font-bold">
              {post.commentCount} تعليق
            </span>
          </div>
        </div>
      </div>

      {/* 2. حاوية إضافة تعليق (محسّنة ولون ناعم يتناسب مع المظهر الداكن) */}
      <div className="rounded-xl border border-border/50 bg-card p-5 text-start shadow-sm">
        {replyingTo && (
          <div className="mb-3 flex items-center justify-between rounded-lg bg-muted/40 p-2.5 px-3 text-sm">
            <span className="font-semibold text-primary">
              رد على @{replyingTo.authorName}
            </span>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setReplyingTo(null)}
              className="h-7 px-2 text-xs text-muted-foreground hover:text-foreground"
            >
              إلغاء <X className="ms-1 h-3.5 w-3.5" />
            </Button>
          </div>
        )}

        {error && (
          <p className="mb-3 rounded bg-destructive/10 p-2 text-sm text-destructive">
            {error}
          </p>
        )}

        <div className="group relative">
          <Textarea
            id="comment-textarea"
            placeholder={
              replyingTo
                ? "اكتب ردك بشكل محترم..."
                : "أضف تعليقاً وشارك أفكارك..."
            }
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            className="min-h-24 resize-y border-border/60 bg-background/50 text-base transition-all placeholder:text-[14px] focus:border-primary"
            dir="rtl"
          />
          <div className="mt-3 flex justify-end gap-2">
            <Button
              onClick={handleSubmitComment}
              disabled={isSubmitting || !newComment.trim()}
              className="px-6 font-semibold tracking-wide shadow-md"
            >
              {isSubmitting
                ? "جاري الإرسال..."
                : replyingTo
                  ? "إرسال الرد"
                  : "إضافة تعليق"}
            </Button>
          </div>
        </div>
      </div>

      {/* 3. شجرة عرض التعليقات أسفل المحتوى */}
      {/* 🚨 تمت إزالة ال orgSlug وال postId لأنهم تسببوا بخطأ Typescript 🚨 */}
      <div className="mt-2 bg-transparent">
        <CommentSection
          comments={comments}
          onReply={handleReply}
          onCommentDeleted={(commentId) => {
            setComments((prev) => prev.filter((c) => c.id !== commentId))
          }}
        />
      </div>
    </div>
  )
}
