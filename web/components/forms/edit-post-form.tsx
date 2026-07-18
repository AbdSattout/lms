"use client"

import { useRouter } from "next/navigation"
import { useState, useTransition } from "react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { updatePost } from "@/lib/actions/post"
import type { CourseResponse, PostResponse } from "@/lib/api/types"
import { toast } from "sonner"
import { Editor } from "../editor"

interface EditPostFormProps {
  orgSlug: string
  post: PostResponse
  courses: CourseResponse[]
}

export function EditPostForm({ orgSlug, post, courses }: EditPostFormProps) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [title, setTitle] = useState(post.title ?? "")
  const [content, setContent] = useState(post.content ?? "")
  const [courseId, setCourseId] = useState<string>(
    post.courseId?.toString() ?? ""
  )

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (!title.trim() || !content.trim()) {
      toast.error("العنوان والمحتوى مطلوبان")
      return
    }

    startTransition(async () => {
      try {
        await updatePost(post.id, orgSlug, {
          title: title.trim(),
          content: content.trim(),
        })
        toast.success("تم تحديث المنشور بنجاح")
        router.push(`/${orgSlug}/posts/${post.id}`)
        router.refresh()
      } catch {
        toast.error("حدث خطأ أثناء تحديث المنشور")
      }
    })
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      <div className="flex flex-col gap-2">
        <Label htmlFor="title">العنوان</Label>
        <Input
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="أدخل عنوان المنشور"
          disabled={isPending}
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="course">الدورة (اختياري)</Label>
        <Select
          value={courseId || undefined}
          onValueChange={(value) => setCourseId(value ?? "")}
          disabled={isPending}
        >
          <SelectTrigger id="course">
            <SelectValue placeholder="اختر دورة..." />
          </SelectTrigger>
          <SelectContent>
            {courses.map((course) => (
              <SelectItem key={course.id} value={course.id.toString()}>
                {course.title}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="flex flex-col gap-2">
        <Label>المحتوى</Label>
        <Editor content={content} onChange={setContent} />
      </div>

      <div className="flex items-center gap-3">
        <Button type="submit" disabled={isPending}>
          {isPending ? "جاري الحفظ..." : "حفظ التعديلات"}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => router.back()}
          disabled={isPending}
        >
          إلغاء
        </Button>
      </div>
    </form>
  )
}
