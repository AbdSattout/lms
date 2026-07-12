"use client"

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle } from "@/components/ui/card"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { CourseResponse } from "@/lib/api/types"
import { Check, EllipsisVertical, Pen, Trash2 } from "lucide-react"
import Image from "next/image"
import { useRouter } from "next/navigation"
import { useState } from "react"

interface CourseCardProps {
  course: CourseResponse
  orgSlug: string
  onEdit: (course: CourseResponse) => void
  onDelete: (course: CourseResponse) => void
  onPublish: (course: CourseResponse) => void
}

function CourseCardMenu({
  course,
  onEdit,
  onDelete,
  onPublish,
}: CourseCardProps) {
  const [publishOpen, setPublishOpen] = useState(false)

  return (
    <>
      <DropdownMenuContent>
        {course.status === "DRAFT" && (
          <DropdownMenuItem onClick={() => setPublishOpen(true)}>
            <Check />
            نشر
          </DropdownMenuItem>
        )}
        <DropdownMenuItem onClick={() => onEdit(course)}>
          <Pen />
          تعديل
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          variant="destructive"
          onClick={() => onDelete(course)}
        >
          <Trash2 />
          حذف
        </DropdownMenuItem>
      </DropdownMenuContent>

      <AlertDialog open={publishOpen} onOpenChange={setPublishOpen}>
        <AlertDialogContent dir="rtl">
          <AlertDialogHeader>
            <AlertDialogTitle>نشر الدورة</AlertDialogTitle>
            <AlertDialogDescription>
              نشر الدورة سيمنعك من تعديل المحتوى (الدروس والبلوكات والأسئلة)
              لاحقاً. هل أنت متأكد؟
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="cursor-pointer">
              إلغاء
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                setPublishOpen(false)
                onPublish(course)
              }}
            >
              نشر
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}

function CourseCardContent(props: CourseCardProps) {
  const { course } = props

  if (course.coverUrl) {
    return (
      <Card className="group relative size-full overflow-hidden">
        <Image
          src={course.coverUrl}
          alt={course.title}
          fill
          priority
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          className="object-cover"
        />
        <div className="absolute inset-0 bg-linear-to-t from-black/80 via-black/30 to-transparent" />
        <CardHeader className="absolute inset-x-0 bottom-3 border-0">
          <div className="flex items-end justify-between gap-4">
            <div className="min-w-0 flex-1">
              <CardTitle className="line-clamp-1 text-white">
                {course.title}
              </CardTitle>
              {course.description && (
                <p className="line-clamp-2 text-sm text-white/75">
                  {course.description}
                </p>
              )}
            </div>
            <span onClick={(e) => e.stopPropagation()}>
              <DropdownMenu>
                <DropdownMenuTrigger
                  render={
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      className="text-white opacity-0 transition-opacity group-hover:opacity-100"
                    />
                  }
                >
                  <EllipsisVertical />
                </DropdownMenuTrigger>
                <CourseCardMenu {...props} />
              </DropdownMenu>
            </span>
          </div>
        </CardHeader>
      </Card>
    )
  }

  return (
    <Card className="size-full overflow-hidden py-3">
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
          <span onClick={(e) => e.stopPropagation()}>
            <DropdownMenu>
              <DropdownMenuTrigger
                render={<Button variant="ghost" size="icon-sm" />}
              >
                <EllipsisVertical />
              </DropdownMenuTrigger>
              <CourseCardMenu {...props} />
            </DropdownMenu>
          </span>
        </div>
      </CardHeader>
    </Card>
  )
}

export function CourseCard(props: CourseCardProps) {
  const router = useRouter()
  const { course, orgSlug } = props
  const href = `/${orgSlug}/courses/${course.slug}`

  return (
    <div
      role="link"
      tabIndex={0}
      className="cursor-pointer"
      onClick={() =>
        router.push(href as unknown as Parameters<typeof router.push>[0])
      }
      onKeyDown={(e) => {
        if (e.key === "Enter")
          router.push(href as unknown as Parameters<typeof router.push>[0])
      }}
    >
      <CourseCardContent {...props} />
    </div>
  )
}
