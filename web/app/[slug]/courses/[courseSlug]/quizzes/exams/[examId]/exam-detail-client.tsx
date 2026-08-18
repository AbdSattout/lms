"use client"

import { QuestionFormDialog } from "@/components/forms/question-form-dialog"
import { QuestionsGrid } from "@/components/questions-grid"
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
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  DropdownMenuItem,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import {
  deletePracticeExamAction,
  publishPracticeExamAction,
  updatePracticeExamQuestionsAction,
} from "@/lib/actions/practice-exams"
import type {
  CourseResponse,
  PracticeExamResponse,
  QuestionResponse,
} from "@/lib/api/types"
import { FileQuestion, Plus, Send, Timer, Trash2 } from "lucide-react"
import { useState } from "react"
import { toast } from "sonner"

interface ExamDetailClientProps {
  course: CourseResponse
  orgSlug: string
  exam: PracticeExamResponse
  bankQuestions: QuestionResponse[]
}

export function ExamDetailClient({
  course,
  orgSlug,
  exam: initialExam,
  bankQuestions: initialBankQuestions,
}: ExamDetailClientProps) {
  const courseId = course.id
  const courseSlug = course.slug
  const [exam, setExam] = useState(initialExam)
  const [bankQuestions, setBankQuestions] = useState(initialBankQuestions)

  const isPublished = exam.status === "PUBLISHED"

  // Add new question dialog
  const [creatingQuestion, setCreatingQuestion] = useState(false)
  const [editingQuestion, setEditingQuestion] =
    useState<QuestionResponse | null>(null)

  // Add from bank dialog
  const [selectFromBankOpen, setSelectFromBankOpen] = useState(false)

  // Remove confirmation
  const [removingQuestion, setRemovingQuestion] =
    useState<QuestionResponse | null>(null)

  // Publish confirmation
  const [publishingExam, setPublishingExam] = useState(false)

  // Delete exam
  const [deletingExam, setDeletingExam] = useState(false)

  async function handlePublish() {
    setPublishingExam(true)
    const result = await publishPracticeExamAction(
      courseId,
      exam.id,
      orgSlug,
      courseSlug
    )
    setPublishingExam(false)

    if (result.error) {
      toast.error(result.error)
      return
    }

    if (result.exam) {
      setExam(result.exam)
      toast.success("تم نشر الامتحان")
    }
  }

  async function handleDeleteExam() {
    const result = await deletePracticeExamAction(
      courseId,
      exam.id,
      orgSlug,
      courseSlug
    )
    if (result.error) {
      toast.error(result.error)
      setDeletingExam(false)
    }
  }

  const examQuestionIds = new Set(exam.questions.map((q) => q.id))
  const availableBankQuestions = bankQuestions.filter(
    (q) => !examQuestionIds.has(q.id)
  )

  async function syncQuestions(newQuestions: QuestionResponse[]) {
    const questionIds = newQuestions.map((q) => q.id)
    const result = await updatePracticeExamQuestionsAction(
      courseId,
      exam.id,
      { questionIds },
      orgSlug,
      courseSlug
    )
    if (result.error) {
      toast.error(result.error)
      return false
    }
    if (result.exam) {
      setExam(result.exam)
    }
    return true
  }

  async function handleQuestionSaved(question: QuestionResponse) {
    setBankQuestions((prev) => {
      const exists = prev.findIndex((q) => q.id === question.id)
      if (exists >= 0) {
        return prev.map((q) => (q.id === question.id ? question : q))
      }
      return [...prev, question]
    })

    const newQuestions = [...exam.questions, question]
    const ok = await syncQuestions(newQuestions)
    if (!ok) {
      setBankQuestions((prev) => prev.filter((q) => q.id !== question.id))
    }
  }

  async function handleAddFromBank(question: QuestionResponse) {
    const newQuestions = [...exam.questions, question]
    const ok = await syncQuestions(newQuestions)
    if (ok) {
      setSelectFromBankOpen(false)
      toast.success("تمت إضافة السؤال إلى الامتحان")
    }
  }

  async function handleRemoveFromExam() {
    const q = removingQuestion
    if (!q) return
    setRemovingQuestion(null)

    const newQuestions = exam.questions.filter((x) => x.id !== q.id)

    if (newQuestions.length === 0) {
      toast.error("يجب أن يحتوي الامتحان على سؤال واحد على الأقل")
      return
    }

    await syncQuestions(newQuestions)
    toast.success("تمت إزالة السؤال من الامتحان")
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2">
            <h2 className="text-lg font-semibold">{exam.title}</h2>
            <Badge variant={isPublished ? "default" : "secondary"}>
              {isPublished ? "منشور" : "مسودة"}
            </Badge>
          </div>
          {exam.description && (
            <p className="text-sm text-muted-foreground">{exam.description}</p>
          )}
          <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
            {exam.timeLimitMinutes ? (
              <span className="flex items-center gap-1">
                <Timer className="size-3" />
                {exam.timeLimitMinutes} دقيقة
              </span>
            ) : (
              <span className="flex items-center gap-1">
                <Timer className="size-3" />
                بدون حد زمني
              </span>
            )}
            <span className="flex items-center gap-1">
              <FileQuestion className="size-3" />
              {exam.questions.length} أسئلة
            </span>
          </div>
        </div>
        <div className="flex gap-2">
          {!isPublished && (
            <>
              <Button onClick={() => setPublishingExam(true)}>
                <Send />
                نشر الامتحان
              </Button>
              <Button
                variant="destructive"
                onClick={() => setDeletingExam(true)}
              >
                <Trash2 />
                حذف الامتحان
              </Button>
            </>
          )}
        </div>
      </div>

      {isPublished && (
        <p className="rounded-xl border border-border bg-card p-3 text-sm text-muted-foreground">
          هذا الامتحان منشور ويمكن للطلاب البدء به الآن. لا يمكن تعديله أو حذفه
          بعد النشر.
        </p>
      )}

      {!isPublished && (
        <div className="flex flex-wrap items-center gap-2">
          <Button onClick={() => setCreatingQuestion(true)}>
            <Plus />
            إضافة سؤال جديد
          </Button>
          <Button
            variant="outline"
            onClick={() => setSelectFromBankOpen(true)}
            disabled={availableBankQuestions.length === 0}
          >
            <Plus />
            إضافة من بنك الأسئلة
          </Button>
        </div>
      )}

      <QuestionsGrid
        questions={exam.questions}
        renderActions={
          isPublished
            ? undefined
            : (q) => (
                <>
                  <DropdownMenuItem
                    onClick={(e) => {
                      e.stopPropagation()
                      setEditingQuestion(q)
                    }}
                  >
                    تعديل
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem
                    variant="destructive"
                    onClick={(e) => {
                      e.stopPropagation()
                      setRemovingQuestion(q)
                    }}
                  >
                    <Trash2 />
                    إزالة من الامتحان
                  </DropdownMenuItem>
                </>
              )
        }
      />

      <QuestionFormDialog
        key={
          creatingQuestion ? "create" : `edit-${editingQuestion?.id ?? "idle"}`
        }
        open={creatingQuestion || !!editingQuestion}
        onOpenChange={(open) => {
          if (!open) {
            setCreatingQuestion(false)
            setEditingQuestion(null)
          }
        }}
        question={editingQuestion}
        courseId={courseId}
        course={course}
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={
          editingQuestion
            ? (q) => {
                setBankQuestions((prev) =>
                  prev.map((x) => (x.id === q.id ? q : x))
                )
                setExam((prev) => ({
                  ...prev,
                  questions: prev.questions.map((x) => (x.id === q.id ? q : x)),
                }))
                setEditingQuestion(null)
              }
            : handleQuestionSaved
        }
      />

      <Dialog open={selectFromBankOpen} onOpenChange={setSelectFromBankOpen}>
        <DialogContent className="max-h-[80dvh] max-w-4xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>اختر سؤالاً من بنك الأسئلة</DialogTitle>
          </DialogHeader>
          <QuestionsGrid
            questions={availableBankQuestions}
            onClick={(q) => handleAddFromBank(q)}
          />
        </DialogContent>
      </Dialog>

      <AlertDialog
        open={!!removingQuestion}
        onOpenChange={(open) => {
          if (!open) setRemovingQuestion(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>إزالة السؤال من الامتحان</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من إزالة هذا السؤال من الامتحان؟ لن يتم حذفه من بنك
              الأسئلة.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleRemoveFromExam}>
              إزالة
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog
        open={publishingExam}
        onOpenChange={(open) => {
          if (!open) setPublishingExam(false)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>نشر الامتحان</AlertDialogTitle>
            <AlertDialogDescription>
              بعد نشر الامتحان سيصبح متاحاً للطلاب ولا يمكن تعديله أو حذفه. هل
              أنت متأكد من النشر؟
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handlePublish}>
              نشر الامتحان
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog
        open={deletingExam}
        onOpenChange={(open) => {
          if (!open) setDeletingExam(false)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الامتحان</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذا الامتحان؟ لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction variant="destructive" onClick={handleDeleteExam}>
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
