"use client"

import { CourseCard } from "@/components/course-card"
import { CourseFormDialog } from "@/components/course-form-dialog"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { deleteCourse } from "@/lib/actions/course"
import type { CourseResponse } from "@/lib/api/types"
import { BookOpen, Plus } from "lucide-react"
import { useState, useTransition } from "react"

interface CoursesContentProps {
  orgSlug: string
  courses: CourseResponse[]
}

export function CoursesContent({ orgSlug, courses }: CoursesContentProps) {
  const [createOpen, setCreateOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)
  const [selectedCourse, setSelectedCourse] = useState<CourseResponse | null>(
    null
  )

  const [isDeleting, startDeleteTransition] = useTransition()
  const [deleteError, setDeleteError] = useState<string | null>(null)

  function handleEdit(course: CourseResponse) {
    setSelectedCourse(course)
    setEditOpen(true)
  }

  function handleDeleteClick(course: CourseResponse) {
    setSelectedCourse(course)
    setDeleteError(null)
    setDeleteOpen(true)
  }

  async function handleDeleteSubmit(formData: FormData) {
    setDeleteError(null)
    startDeleteTransition(async () => {
      const result = await deleteCourse({}, formData)
      if (result.error) {
        setDeleteError(result.error!)
      } else {
        setDeleteOpen(false)
        setSelectedCourse(null)
      }
    })
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">الدورات</h1>
        <Button onClick={() => setCreateOpen(true)}>
          <Plus />
          إضافة دورة
        </Button>
      </div>

      {courses.length === 0 ? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <BookOpen />
            </EmptyMedia>
            <EmptyTitle>لا توجد دورات بعد</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>
            <Button onClick={() => setCreateOpen(true)}>
              <Plus />
              إضافة دورة
            </Button>
          </EmptyContent>
        </Empty>
      ) : (
        <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4 *:aspect-video *:min-h-0 *:w-full">
          {courses.map((course) => (
            <CourseCard
              key={course.id}
              course={course}
              onEdit={handleEdit}
              onDelete={handleDeleteClick}
            />
          ))}
        </div>
      )}

      <CourseFormDialog
        key="create"
        open={createOpen}
        onOpenChange={setCreateOpen}
        orgSlug={orgSlug}
      />

      <CourseFormDialog
        key={selectedCourse?.id ?? "edit"}
        open={editOpen}
        onOpenChange={setEditOpen}
        orgSlug={orgSlug}
        course={selectedCourse ?? undefined}
      />

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>حذف الدورة</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف دورة &quot;{selectedCourse?.title}&quot;؟ لا
              يمكن التراجع عن هذا الإجراء.
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={(e) => {
              e.preventDefault()
              handleDeleteSubmit(new FormData(e.currentTarget))
            }}
          >
            <input type="hidden" name="courseId" value={selectedCourse?.id} />
            <input type="hidden" name="orgSlug" value={orgSlug} />
            {deleteError && (
              <p className="mb-2 text-sm text-destructive">{deleteError}</p>
            )}
            <div className="flex justify-end gap-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setDeleteOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit" variant="destructive" disabled={isDeleting}>
                {isDeleting ? "جاري الحذف..." : "حذف"}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
