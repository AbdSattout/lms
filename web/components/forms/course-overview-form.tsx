// components/courses-dialog.tsx
"use client"

import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Progress } from "../ui/progress"
import { BookOpen, BookCheck, PenTool } from "lucide-react"

interface CoursesDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  publishedCount: number
  draftCount: number
}

export function CoursesOverviewDialog({
  open,
  onOpenChange,
  publishedCount,
  draftCount,
}: CoursesDialogProps) {
  const totalCourses = publishedCount + draftCount
  const publishedPercentage =
    totalCourses > 0 ? Math.round((publishedCount / totalCourses) * 100) : 0
  const draftPercentage =
    totalCourses > 0 ? Math.round((draftCount / totalCourses) * 100) : 0

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent
        className="flex h-[85vh] w-full flex-col gap-0 overflow-hidden border-muted/50 p-0 shadow-lg sm:h-auto sm:max-w-[420px] sm:rounded-xl"
        dir="rtl"
      >
        <div className="flex h-14 shrink-0 items-center justify-center border-b bg-muted/30 p-4">
          <DialogTitle className="text-[15px] font-bold tracking-wide">
            تفاصيل الدورات
          </DialogTitle>
        </div>

        <div className="grid grid-cols-1 gap-4 p-6">
          {/* Total Courses */}
          <div className="flex items-center justify-between rounded-lg bg-muted/50 p-4">
            <div className="flex items-center gap-3">
              <BookOpen className="h-8 w-8 text-primary" />
              <div>
                <p className="text-sm font-medium text-muted-foreground">
                  إجمالي الدورات
                </p>
                <p className="text-2xl font-bold text-foreground">
                  {totalCourses}
                </p>
              </div>
            </div>
          </div>

          {/* Published Courses */}
          <div className="space-y-3 rounded-lg bg-emerald-50 p-4 dark:bg-emerald-950/20">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <BookCheck className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
                <div>
                  <p className="text-sm font-medium text-emerald-700 dark:text-emerald-300">
                    الدورات المنشورة
                  </p>
                  <p className="text-2xl font-bold text-emerald-800 dark:text-emerald-200">
                    {publishedCount}
                  </p>
                </div>
              </div>
              {totalCourses > 0 && (
                <div className="text-lg font-bold text-emerald-600 dark:text-emerald-400">
                  {publishedPercentage}%
                </div>
              )}
            </div>
            {totalCourses > 0 && (
              <Progress
                value={publishedPercentage}
                className="h-2 bg-emerald-200 dark:bg-emerald-800"
              />
            )}
          </div>

          {/* Draft Courses */}
          <div className="space-y-3 rounded-lg bg-amber-50 p-4 dark:bg-amber-950/20">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <PenTool className="h-8 w-8 text-amber-600 dark:text-amber-400" />
                <div>
                  <p className="text-sm font-medium text-amber-700 dark:text-amber-300">
                    الدورات المسودة
                  </p>
                  <p className="text-2xl font-bold text-amber-800 dark:text-amber-200">
                    {draftCount}
                  </p>
                </div>
              </div>
              {totalCourses > 0 && (
                <div className="text-lg font-bold text-amber-600 dark:text-amber-400">
                  {draftPercentage}%
                </div>
              )}
            </div>
            {totalCourses > 0 && (
              <Progress
                value={draftPercentage}
                className="h-2 bg-amber-200 dark:bg-amber-800"
              />
            )}
          </div>

          {/* Empty State */}
          {totalCourses === 0 && (
            <div className="py-4 text-center text-sm text-muted-foreground">
              لا توجد دورات بعد
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
