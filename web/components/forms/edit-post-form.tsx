"use client"

import type { Route } from "next"
import { useRouter } from "next/navigation"
import { useState, useTransition } from "react"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Editor } from "@/components/editor"
import { Input } from "@/components/ui/input"
import { updatePost } from "@/lib/actions/post"

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

import type { CourseResponse, PostResponse } from "@/lib/api/types"

interface Props {
  orgSlug: string
  post: PostResponse
  courses: CourseResponse[]
}

export function EditPostForm({ orgSlug, post, courses }: Props) {
  const router = useRouter()

  const [title, setTitle] = useState(post.title || "")
  const [content, setContent] = useState(post.content || "")

  const [courseId, setCourseId] = useState<number | null>(post.courseId ?? null)

  const selectedCourse = courses.find((c) => c.id === courseId)

  const [error, setError] = useState<string | null>(null)

  const [isSubmitting, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (!title.trim()) {
      setError("العنوان مطلوب")
      return
    }

    if (!content.trim()) {
      setError("المحتوى مطلوب")
      return
    }

    setError(null)

    startTransition(async () => {
      try {
        await updatePost(orgSlug, post.id, {
          title: title.trim(),
          content: content.trim(),
          courseId: courseId === null ? undefined : courseId,
        })

        toast.success("تم تعديل المنشور")

        router.push(`/${orgSlug}/posts/${post.id}` as Route)
        router.refresh()
      } catch (err) {
        console.error("Failed to update post:", err)
        setError("فشل تعديل المنشور")
      }
    })
  }

  return (
    <div className="mx-auto w-full max-w-4xl pt-6">
      <form
        onSubmit={handleSubmit}
        className="flex flex-col gap-8 rounded-xl border border-border/50 bg-card p-6 text-start text-card-foreground shadow-sm md:p-8"
      >
        <div className="border-b border-border/50 pb-5">
          <h1 className="text-2xl font-extrabold">تعديل المنشور</h1>
          <p className="mt-2 text-[14px] text-muted-foreground">
            قم بتعديل محتوى المنشور الحالي
          </p>
        </div>

        {error && (
          <div className="rounded-md bg-destructive/10 p-3 text-destructive">
            {error}
          </div>
        )}

        <div className="flex flex-col gap-3 text-start">
          <label htmlFor="title" className="text-sm font-bold">
            العنوان
          </label>
          <Input
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={isSubmitting}
            dir="rtl"
            className="h-12 border-border/60 bg-background/50 text-lg"
            placeholder="عنوان المنشور"
          />
        </div>

        {courses.length > 0 && (
          <div className="flex flex-col gap-3 text-start">
            <label className="text-sm font-bold">مرتبط بدورة (اختياري)</label>
            <Select
              value={courseId?.toString() ?? "none"}
              onValueChange={(v) =>
                setCourseId(v === "none" ? null : Number(v))
              }
            >
              <SelectTrigger dir="rtl" className="h-11 bg-background/50">
                <SelectValue>
                  {selectedCourse?.title ?? "اختر دورة لربط المنشور بها"}
                </SelectValue>
              </SelectTrigger>

              <SelectContent dir="rtl">
                <SelectItem value="none">بدون دورة</SelectItem>
                {courses.map((course) => (
                  <SelectItem key={course.id} value={course.id.toString()}>
                    {course.title}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        )}

        <div className="flex flex-col gap-3 text-start">
          <label className="text-sm font-bold">المحتوى</label>
          <div className="min-h-[300px] overflow-hidden rounded-xl border border-border/60 bg-background/80 shadow-sm transition-all focus-within:border-primary focus-within:ring-1 focus-within:ring-primary">
            <Editor content={content} onChange={setContent} />
          </div>
        </div>

        <div className="flex justify-end gap-3 border-t border-border/40 pt-5">
          <Button
            type="button"
            variant="secondary"
            onClick={() => router.back()}
            disabled={isSubmitting}
            className="w-24"
          >
            إلغاء
          </Button>

          <Button type="submit" disabled={isSubmitting} className="w-40">
            {isSubmitting ? "جارٍ الحفظ..." : "حفظ التعديلات"}
          </Button>
        </div>
      </form>
    </div>
  )
}
