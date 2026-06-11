"use client"

import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle } from "@/components/ui/card"
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
import { deleteCourseCover } from "@/lib/actions/course"
import type { CourseResponse } from "@/lib/api/types"
import { EllipsisVertical, ImageMinus, Pen, Trash2 } from "lucide-react"
import Image from "next/image"
import { useState, useTransition } from "react"

interface CourseCardProps {
  course: CourseResponse
  orgSlug: string
  onEdit: (course: CourseResponse) => void
  onDelete: (course: CourseResponse) => void
}

export function CourseCard({
  course,
  orgSlug,
  onEdit,
  onDelete,
}: CourseCardProps) {
  const [deleteCoverOpen, setDeleteCoverOpen] = useState(false)
  const [isDeletingCover, startDeleteCoverTransition] = useTransition()

  function handleDeleteCoverSubmit() {
    startDeleteCoverTransition(async () => {
      const result = await deleteCourseCover(course.id!, orgSlug)
      if (result.success) setDeleteCoverOpen(false)
    })
  }
  return (
    <>
      {course.coverUrl ? (
        <Card className="relative aspect-video overflow-hidden">
          <Image
            src={course.coverUrl}
            alt={course.title ?? ""}
            fill
            priority
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover"
          />
          <div className="absolute inset-0 bg-linear-to-t from-black/80 via-black/30 to-transparent" />
          <CardHeader className="absolute inset-x-0 bottom-3 border-0">
            <div className="flex items-end justify-between gap-4">
              <div className="min-w-0 flex-1">
                <CardTitle className="line-clamp-1">{course.title}</CardTitle>
                {course.description && (
                  <p className="line-clamp-2 text-sm text-muted-foreground">
                    {course.description}
                  </p>
                )}
              </div>
              <DropdownMenu>
                <DropdownMenuTrigger
                  render={<Button variant="ghost" size="icon-sm" />}
                >
                  <EllipsisVertical />
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuItem onClick={() => onEdit(course)}>
                    <Pen />
                    تعديل
                  </DropdownMenuItem>
                  {course.coverUrl && (
                    <DropdownMenuItem onClick={() => setDeleteCoverOpen(true)}>
                      <ImageMinus />
                      حذف الغلاف
                    </DropdownMenuItem>
                  )}
                  <DropdownMenuItem
                    variant="destructive"
                    onClick={() => onDelete(course)}
                  >
                    <Trash2 />
                    حذف
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </CardHeader>
        </Card>
      ) : (
        <Card className="overflow-hidden py-3">
          <CardHeader className="mt-auto">
            <div className="flex items-end justify-between gap-4">
              <div className="min-w-0 flex-1">
                <CardTitle className="line-clamp-1">{course.title}</CardTitle>
                {course.description && (
                  <p className="line-clamp-2 text-sm text-muted-foreground">
                    {course.description}
                  </p>
                )}
              </div>
              <DropdownMenu>
                <DropdownMenuTrigger
                  render={<Button variant="ghost" size="icon-sm" />}
                >
                  <EllipsisVertical />
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuItem onClick={() => onEdit(course)}>
                    <Pen />
                    تعديل
                  </DropdownMenuItem>
                  {course.coverUrl && (
                    <DropdownMenuItem onClick={() => setDeleteCoverOpen(true)}>
                      <ImageMinus />
                      حذف الغلاف
                    </DropdownMenuItem>
                  )}
                  <DropdownMenuItem
                    variant="destructive"
                    onClick={() => onDelete(course)}
                  >
                    <Trash2 />
                    حذف
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </CardHeader>
        </Card>
      )}

      <Dialog open={deleteCoverOpen} onOpenChange={setDeleteCoverOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>حذف الغلاف</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف غلاف الدورة؟ لا يمكن التراجع عن هذا الإجراء.
            </DialogDescription>
          </DialogHeader>
          <div className="flex justify-end gap-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => setDeleteCoverOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              type="submit"
              variant="destructive"
              disabled={isDeletingCover}
              onClick={handleDeleteCoverSubmit}
            >
              {isDeletingCover ? "جاري الحذف..." : "حذف"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
