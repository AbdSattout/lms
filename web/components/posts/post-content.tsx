"use client"

import type { Route } from "next"
import Link from "next/link"
import { useCallback, useEffect, useRef, useState, useTransition } from "react"
import { FileText, Plus } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import type { PostResponse } from "@/lib/api/types"
import { PostCardSkeleton } from "@/components/skeletons/post-card-skeleton"
import { PostCard } from "../cards/post-card" // تأكد من مسار الاستيراد لديك
import { getPostsByOrg } from "@/lib/actions/post"

interface PostsContentProps {
  orgSlug: string
  initialPosts: PostResponse[]
  initialHasMore: boolean
}

export function PostsContent({
  orgSlug,
  initialPosts,
  initialHasMore,
}: PostsContentProps) {
  const [posts, setPosts] = useState<PostResponse[]>(initialPosts)
  const [hasMore, setHasMore] = useState(initialHasMore)
  const [page, setPage] = useState(1)

  // 1. الحل الأمثل لمزامنة البيانات بدون استخدام useEffect
  // نقوم بحفظ نسخة من البيانات القادمة من السيرفر، وإذا تغيرت نقوم بتحديث الـ State فوراً
  const [prevInitialPosts, setPrevInitialPosts] = useState(initialPosts)

  if (initialPosts !== prevInitialPosts) {
    setPrevInitialPosts(initialPosts)
    setPosts(initialPosts)
    setHasMore(initialHasMore)
    setPage(1)
  }

  const [isLoadingMore, startLoadingMore] = useTransition()
  const observerRef = useRef<IntersectionObserver | null>(null)
  const loadMoreRef = useRef<HTMLDivElement>(null)

  const loadMore = useCallback(() => {
    if (!hasMore || isLoadingMore) return
    startLoadingMore(async () => {
      try {
        const result = await getPostsByOrg(orgSlug, {
          page,
          size: 20,
          sort: ["createdAt,desc"], // تصحيح الفرز
        })

        const fetchedPosts = result.content ?? []

        if (fetchedPosts.length > 0) {
          setPosts((prev) => {
            const newPosts = [...prev, ...fetchedPosts]
            setHasMore(newPosts.length < (result.totalElements ?? 0))
            return newPosts
          })
          setPage((prev) => prev + 1)
        } else {
          setHasMore(false)
        }
      } catch (error) {
        console.error("Error fetching more posts", error)
        setHasMore(false) // إيقاف المحاولة عند حدوث خطأ
      }
    })
  }, [hasMore, isLoadingMore, orgSlug, page])

  useEffect(() => {
    const el = loadMoreRef.current
    if (!el) return

    observerRef.current = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting && hasMore) {
          loadMore()
        }
      },
      { threshold: 0.1 }
    )

    observerRef.current.observe(el)
    return () => observerRef.current?.disconnect()
  }, [loadMore, hasMore])

  const handlePostDeleted = useCallback((postId: number) => {
    setPosts((prev) => prev.filter((p) => p.id !== postId))
  }, [])

  if (posts.length === 0) {
    return (
      <Empty>
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <FileText className="h-10 w-10 text-muted-foreground" />
          </EmptyMedia>
          <EmptyTitle>لا توجد منشورات بعد</EmptyTitle>
        </EmptyHeader>
        <EmptyContent>
          {/* 2. إزالة asChild من هنا */}
          <Button>
            <Link
              href={`/${orgSlug}/posts/create` as Route}
              className="flex items-center gap-2"
            >
              <Plus className="h-4 w-4" />
              إنشاء منشور
            </Link>
          </Button>
        </EmptyContent>
      </Empty>
    )
  }

  return (
    <div className="mx-auto flex w-full max-w-[700px] flex-col gap-6 px-4 pt-6 pb-12">
      <div className="flex items-center justify-between border-b border-border/40 pb-5">
        <h1 className="text-[1.7rem] font-extrabold tracking-tight">
          المنشورات
        </h1>

        {/* 🔴 تم إصلاح زر "إنشاء منشور" ليستخدم Link بتنسيق الزر مباشرة (شبه Shadcn تماماً) بلا استخدام <Button> */}
        <Link
          href={`/${orgSlug}/posts/create` as Route}
          className="inline-flex h-10 items-center justify-center gap-2 rounded-lg bg-primary px-5 py-2 text-sm font-semibold whitespace-nowrap text-primary-foreground ring-offset-background transition-colors hover:bg-primary/90 focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none"
        >
          <Plus className="h-[18px] w-[18px]" strokeWidth={2.5} />
          <span>إنشاء منشور</span>
        </Link>
      </div>

      <div className="flex flex-col gap-5">
        {posts.map((post) => (
          <PostCard
            key={post.id}
            post={post}
            orgSlug={orgSlug}
            onDeleted={handlePostDeleted}
          />
        ))}
      </div>

      {hasMore && (
        <div ref={loadMoreRef} className="flex justify-center py-4">
          {isLoadingMore ? (
            <div className="flex w-full flex-col gap-4">
              {Array.from({ length: 3 }).map((_, i) => (
                <PostCardSkeleton key={i} />
              ))}
            </div>
          ) : null}
        </div>
      )}

      {!hasMore && posts.length > 0 && (
        <p className="py-4 text-center text-sm text-muted-foreground">
          تم تحميل جميع المنشورات
        </p>
      )}
    </div>
  )
}
