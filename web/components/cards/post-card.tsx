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

  // تم استرجاع دالتك الأصلية والممتازة لأنها تستخرج أول حرف من كل كلمة (Iyad Karima -> IK)
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

  const thumbnailMatch = post.content?.match(/!\[.*?\]\((.*?)\)/)
  const thumbnail = thumbnailMatch?.[1] ?? null
  const previewText =
    post.content
      ?.replace(/!\[.*?\]\(.*?\)/g, "")
      .replace(/\[([^\]]+)\]\(.*?\)/g, "$1")
      .replace(/[#*`>~\-_]/g, "")
      .trim()
      .slice(0, 200) ?? ""

  return (
    <>
      <div className="group/card relative flex flex-col rounded-xl border border-border/40 bg-card text-start text-card-foreground shadow-sm transition-colors hover:bg-muted/40">
        <div className="p-4 md:px-5 md:py-4">
          {/* جزء المستخدم والتوقيت والإعدادات */}
          <div className="relative z-10 mb-4 flex items-start justify-between gap-2">
            <div className="flex min-w-0 items-center gap-3">
              <Avatar className="h-9 w-9 shrink-0 ring-1 ring-border/30">
                <AvatarImage src={post.author?.picture} />
                <AvatarFallback>{authorInitials}</AvatarFallback>
              </Avatar>
              <div className="flex flex-col text-start">
                <span className="truncate text-sm font-semibold">
                  {post.author?.name ?? "مستخدم"}
                </span>
                <span className="text-[13px] text-muted-foreground">
                  {timeAgo}
                </span>
              </div>
            </div>

            {isAuthor && (
              <DropdownMenu>
                {/* استبدلنا الـ Button هنا فقط لمنع الأخطاء الحمراء (Hydration error) وتم إعطاء هذا الزر تنسيقات أزرار Tailwind لتظهر بشكل أنيق */}
                <DropdownMenuTrigger className="flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-md text-muted-foreground transition-colors outline-none hover:bg-black/10 hover:text-foreground focus:bg-accent focus:text-foreground">
                  <MoreHorizontal className="h-5 w-5" />
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" dir="rtl">
                  <DropdownMenuItem>
                    {/* تم التأكد من بقاء مسارات الـ Routes سليمة الخاصة بك */}
                    <Link
                      href={`/${orgSlug}/posts/${post.id}/edit` as Route}
                      className="cursor-pointer"
                    >
                      <Pencil className="ml-2 h-4 w-4" /> تعديل
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    className="cursor-pointer text-destructive focus:bg-destructive/10 focus:text-destructive"
                    onClick={() => setDeleteOpen(true)}
                  >
                    <Trash2 className="ml-2 h-4 w-4" /> حذف
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>

          {/* محتوى المنشور والـ Reddit Layout Clickable  */}
          {/* خصائص ال before هي المسؤولة عن جعل كل مساحة المنشور قابلة للضغط بسهولة ونعومة دون إعاقة الأزرار الاخرى */}
          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="group block cursor-pointer outline-none before:absolute before:inset-0 before:z-0"
          >
            <h3 className="mb-2 text-lg leading-tight font-bold transition-colors group-hover:text-primary">
              {post.title}
            </h3>

            {thumbnail && (
              <div className="relative mb-3 h-52 w-full overflow-hidden rounded-xl border border-border/40">
                <Image
                  src={thumbnail}
                  alt=""
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 100vw, 600px"
                />
              </div>
            )}

            {previewText && (
              <p className="mb-3 line-clamp-3 text-[15px] leading-relaxed text-muted-foreground">
                {previewText}
              </p>
            )}
          </Link>
        </div>

        {/* الشريط السفلي (التفاعل) z-10 مهم جدا هنا عشان تضل قابلة للضغط منفردة ولا يفتح رابط المنشور ككل! */}
        <div className="relative z-10 mt-auto flex items-center gap-5 border-t border-border/40 px-4 py-3 md:px-5">
          <button className="flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-red-500">
            <Heart className="h-5 w-5" />
            <span className="text-sm font-medium">{post.likeCount || 0}</span>
          </button>

          <Link
            href={`/${orgSlug}/posts/${post.id}` as Route}
            className="flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-primary"
          >
            <MessageCircle className="h-5 w-5" />
            <span className="text-sm font-medium">
              {post.commentCount || 0} تعليق
            </span>
          </Link>
        </div>
      </div>

      {/* النافذة المنبثقة للتأكيد من حذفك - كما كتبتها أنت 100% */}
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
              {isDeleting ? "جاري الحذف..." : "حذف تأكيد"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
