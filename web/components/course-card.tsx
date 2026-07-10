"use client"

import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle } from "@/components/ui/card"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { CourseResponse } from "@/lib/api/types"
import { EllipsisVertical, Pen, Trash2 } from "lucide-react"
import Image from "next/image"

interface CourseCardProps {
  course: CourseResponse
  onEdit: (course: CourseResponse) => void
  onDelete: (course: CourseResponse) => void
}

export function CourseCard({ course, onEdit, onDelete }: CourseCardProps) {
  return (
    <>
      {course.coverUrl ? (
        <Card className="group relative overflow-hidden">
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
                <CardTitle className="line-clamp-1 text-white">
                  {course.title}
                </CardTitle>
                {course.description && (
                  <p className="line-clamp-2 text-sm text-white/75">
                    {course.description}
                  </p>
                )}
              </div>
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
                <DropdownMenuContent>
                  <DropdownMenuItem onClick={() => onEdit(course)}>
                    <Pen />
                    تعديل
                  </DropdownMenuItem>
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
    </>
  )
}
