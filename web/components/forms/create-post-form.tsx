// components/forms/create-post-form.tsx
"use client"

import type { Route } from "next"
import { useRouter } from "next/navigation"
import { useState, useTransition } from "react"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Editor } from "@/components/editor"
import { Input } from "@/components/ui/input"
import { createPost } from "@/lib/actions/post"
// استيراد مكونات Select من مكتبتك
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import type { CourseResponse } from "@/lib/api/types" // تأكد من المسار الصحيح

interface CreatePostFormProps {
  orgSlug: string
  courses?: CourseResponse[] // إضافة الدورات للـ Props
}

export function CreatePostForm({ orgSlug, courses = [] }: CreatePostFormProps) {
  const router = useRouter()
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [courseId, setCourseId] = useState<number | null>(null) // State لتخزين الـ Course ID
  const [isSubmitting, startSubmit] = useTransition()
  const [error, setError] = useState<string | null>(null)

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
    startSubmit(async () => {
      try {
        const post = await createPost(orgSlug, {
          title: title.trim(),
          content: content.trim(),
          courseId: courseId, // إرسال معرف الدورة أو null هنا
        })
        toast.success("تم إنشاء المنشور بنجاح")
        router.push(`/${orgSlug}/posts/${post.id}` as Route)
      } catch {
        setError("فشل إنشاء المنشور. يرجى المحاولة مرة أخرى.")
      }
    })
  }

  return (
    // الإطار العام للفورم - توسيط وحجم مثالي وخلفية البطاقات الساطعة/المعتمة
    <div className="mx-auto w-full max-w-4xl pt-6">
      <form
        onSubmit={handleSubmit}
        className="flex flex-col gap-8 rounded-xl border border-border/50 bg-card p-6 text-start text-card-foreground shadow-sm md:p-8"
      >
        <div className="border-b border-border/50 pb-5">
          <h1 className="text-2xl font-extrabold">إنشاء منشور</h1>
          <p className="mt-2 text-[14px] text-muted-foreground">
            قم بنشر معلومات ونصائح أو مناقشات لمنظمتك بكل سهولة
          </p>
        </div>

        {error && (
          <div className="rounded-lg border border-destructive/50 bg-destructive/10 p-3 font-medium text-destructive">
            {error}
          </div>
        )}

        {/* خانة العنوان */}
        <div className="flex flex-col gap-3 text-start">
          <label
            htmlFor="title"
            className="text-sm font-bold text-card-foreground"
          >
            العنوان
          </label>
          <Input
            id="title"
            placeholder="أدخل عنوان المنشور بوضوح..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="h-12 border-border/60 bg-background/50 text-lg transition-all focus:border-primary focus:bg-background"
            dir="rtl"
          />
        </div>

        {/* قائمة الدورة (إن أردت إضافة select كما طلبته بالماضي ضعها هنا كالتالي) */}
        {courses && courses.length > 0 && (
          <div className="flex flex-col gap-3 text-start">
            <label className="text-sm font-bold text-card-foreground">
              مرتبط بدورة (اختياري)
            </label>
            <Select
              onValueChange={(value) =>
                setCourseId(value === "none" ? null : Number(value))
              }
            >
              <SelectTrigger
                className="h-11 w-full bg-background/50 text-right"
                dir="rtl"
              >
                <SelectValue placeholder="اختر دورة لربط المنشور بها..." />
              </SelectTrigger>
              <SelectContent dir="rtl" className="max-h-60">
                <SelectItem value="none">بدون دورة (غير مرتبط)</SelectItem>
                {courses.map((course) => (
                  <SelectItem key={course.id} value={course.id.toString()}>
                    {course.title}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        )}

        {/* Editor المحتوى */}
        <div className="flex flex-col gap-3 text-start">
          <label className="flex items-center justify-between text-sm font-bold text-card-foreground">
            المحتوى
          </label>
          {/* تحسين مظهر الأديتور بحدود أقوى وظل بسيط */}
          <div className="min-h-[300px] overflow-hidden rounded-xl border border-border/60 bg-background/80 shadow-sm transition-all focus-within:border-primary focus-within:ring-1 focus-within:ring-primary">
            <Editor onChange={setContent} content={content} />
          </div>
        </div>

        {/* شريط الإجراء السفلي */}
        <div className="mt-2 flex items-center justify-end gap-4 border-t border-border/40 pt-5">
          <Button
            type="button"
            variant="secondary"
            onClick={() => router.back()}
            disabled={isSubmitting}
            className="w-24 bg-secondary text-secondary-foreground"
          >
            إلغاء
          </Button>
          <Button
            type="submit"
            disabled={isSubmitting}
            className="w-32 shadow-md"
          >
            {isSubmitting ? "يتم النشر..." : "نشر "}
          </Button>
        </div>
      </form>
    </div>
  )
}
