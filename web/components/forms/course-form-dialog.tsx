"use client"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { createCourse, updateCourse } from "@/lib/actions/course"
import type { CourseResponse } from "@/lib/api/types"
import { generateSlug } from "@/lib/utils"
import { useActionState, useEffect, useRef, useState } from "react"

interface CourseFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  orgSlug: string
  course?: CourseResponse
}

export function CourseFormDialog({
  open,
  onOpenChange,
  orgSlug,
  course,
}: CourseFormDialogProps) {
  const isEdit = !!course
  const action = isEdit ? updateCourse : createCourse
  const [state, formAction, isPending] = useActionState(action, {})

  const [slug, setSlug] = useState(course?.slug ?? "")
  const userEditedSlug = useRef(false)

  useEffect(() => {
    if (state.success) {
      onOpenChange(false)
    }
  }, [state, onOpenChange])

  function handleTitleChange(value: string) {
    if (userEditedSlug.current) return
    const generated = generateSlug(value, "course")
    if (generated !== null) setSlug(generated)
  }

  function handleSlugChange(value: string) {
    userEditedSlug.current = true
    const filtered = value.replace(/[^a-z0-9-]/g, "")
    setSlug(filtered)
    if (!filtered) {
      userEditedSlug.current = false
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {isEdit ? "تعديل الدورة" : "إضافة دورة جديدة"}
          </DialogTitle>
        </DialogHeader>
        <form action={formAction} className="flex flex-col gap-4">
          <input type="hidden" name="orgSlug" value={orgSlug} />
          {isEdit && <input type="hidden" name="courseId" value={course.id} />}

          <div className="flex flex-col gap-2">
            <Label htmlFor="title">العنوان</Label>
            <Input
              id="title"
              name="title"
              required
              defaultValue={course?.title ?? ""}
              disabled={isPending}
              onChange={(e) => {
                if (!isEdit) handleTitleChange(e.target.value)
              }}
            />
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="slug">الرابط</Label>
            <Input
              id="slug"
              name="slug"
              dir="ltr"
              value={slug}
              onChange={(e) => handleSlugChange(e.target.value)}
              placeholder="my-course"
              disabled={isPending}
              required
            />
            <p className="text-xs text-muted-foreground">
              أحرف إنجليزية صغيرة وشرطات فقط
            </p>
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="description">الوصف</Label>
            <Textarea
              id="description"
              name="description"
              defaultValue={course?.description ?? ""}
              disabled={isPending}
            />
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="cover">صورة الغلاف</Label>
            <Input
              id="cover"
              name="cover"
              type="file"
              accept="image/*"
              disabled={isPending}
            />
          </div>

          {state.error && (
            <p className="text-sm text-destructive">{state.error}</p>
          )}

          <Button
            type="submit"
            disabled={isPending}
            className="w-full cursor-pointer"
          >
            {isPending
              ? "جاري الحفظ..."
              : isEdit
                ? "حفظ التغييرات"
                : "إضافة الدورة"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}
