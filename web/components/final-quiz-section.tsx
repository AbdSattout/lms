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
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { Separator } from "@/components/ui/separator"
import { updateFinalQuizQuestionsAction } from "@/lib/actions/quizzes"
import type { QuestionResponse, QuizResponse } from "@/lib/api/types"
import { ClipboardList, Plus, Trash2 } from "lucide-react"
import { useState } from "react"
import { toast } from "sonner"

interface FinalQuizSectionProps {
  courseId: number
  orgSlug: string
  courseSlug: string
  initialQuiz: QuizResponse | null
  initialBankQuestions: QuestionResponse[]
  isEditable: boolean
}

export function FinalQuizSection({
  courseId,
  orgSlug,
  courseSlug,
  initialQuiz,
  initialBankQuestions,
  isEditable,
}: FinalQuizSectionProps) {
  const [quiz, setQuiz] = useState(initialQuiz)
  const [bankQuestions, setBankQuestions] = useState(initialBankQuestions)

  const [creatingQuestion, setCreatingQuestion] = useState(false)
  const [editingQuestion, setEditingQuestion] =
    useState<QuestionResponse | null>(null)
  const [selectFromBankOpen, setSelectFromBankOpen] = useState(false)
  const [removingQuestion, setRemovingQuestion] =
    useState<QuestionResponse | null>(null)

  const quizQuestionIds = new Set(quiz?.questions.map((q) => q.id) ?? [])
  const availableBankQuestions = bankQuestions.filter(
    (q) => !quizQuestionIds.has(q.id)
  )

  async function syncQuestions(newQuestions: QuestionResponse[]) {
    const questionIds = newQuestions.map((q) => q.id)
    const result = await updateFinalQuizQuestionsAction(
      courseId,
      { questionIds },
      orgSlug,
      courseSlug
    )
    if (result.error) {
      toast.error(result.error)
      return false
    }
    if (result.quiz) {
      setQuiz(result.quiz)
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

    const currentQuestions = quiz?.questions ?? []
    const newQuestions = [...currentQuestions, question]
    const ok = await syncQuestions(newQuestions)
    if (!ok) {
      setBankQuestions((prev) => prev.filter((q) => q.id !== question.id))
    }
  }

  async function handleAddFromBank(question: QuestionResponse) {
    const currentQuestions = quiz?.questions ?? []
    const newQuestions = [...currentQuestions, question]
    const ok = await syncQuestions(newQuestions)
    if (ok) {
      setSelectFromBankOpen(false)
      toast.success("تمت إضافة السؤال إلى الاختبار النهائي")
    }
  }

  async function handleRemoveFromQuiz() {
    const q = removingQuestion
    if (!q) return
    setRemovingQuestion(null)

    const currentQuestions = quiz?.questions ?? []
    const newQuestions = currentQuestions.filter((x) => x.id !== q.id)

    if (newQuestions.length === 0) {
      toast.error("يجب أن يحتوي الاختبار النهائي على سؤال واحد على الأقل")
      return
    }

    await syncQuestions(newQuestions)
    toast.success("تمت إزالة السؤال من الاختبار النهائي")
  }

  const questions = quiz?.questions ?? []

  return (
    <div className="flex flex-col gap-4">
      <Separator />

      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">الاختبار النهائي</h2>
        {isEditable && (
          <div className="flex flex-wrap items-center gap-2">
            <Button
              variant="outline"
              onClick={() => setSelectFromBankOpen(true)}
              disabled={availableBankQuestions.length === 0}
            >
              <Plus />
              إضافة من بنك الأسئلة
            </Button>
            <Button onClick={() => setCreatingQuestion(true)}>
              <Plus />
              إضافة سؤال جديد
            </Button>
          </div>
        )}
      </div>

      {questions.length === 0 ? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <ClipboardList />
            </EmptyMedia>
            <EmptyTitle>لا توجد أسئلة في الاختبار النهائي</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>
            لم يتم إضافة أسئلة للاختبار النهائي بعد. أضف أسئلة من بنك الأسئلة أو
            أنشئ أسئلة جديدة.
          </EmptyContent>
        </Empty>
      ) : (
        <QuestionsGrid
          questions={questions}
          renderActions={(q) => (
            <>
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation()
                  setEditingQuestion(q)
                }}
              >
                تعديل
              </DropdownMenuItem>
              {isEditable && (
                <>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem
                    variant="destructive"
                    onClick={(e) => {
                      e.stopPropagation()
                      setRemovingQuestion(q)
                    }}
                  >
                    <Trash2 />
                    إزالة من الاختبار النهائي
                  </DropdownMenuItem>
                </>
              )}
            </>
          )}
        />
      )}

      <QuestionFormDialog
        key={
          creatingQuestion
            ? "create-final"
            : `edit-final-${editingQuestion?.id ?? "idle"}`
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
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={
          editingQuestion
            ? (q) => {
                setBankQuestions((prev) =>
                  prev.map((x) => (x.id === q.id ? q : x))
                )
                setQuiz((prev) =>
                  prev
                    ? {
                        ...prev,
                        questions: prev.questions.map((x) =>
                          x.id === q.id ? q : x
                        ),
                      }
                    : prev
                )
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
            <AlertDialogTitle>
              إزالة السؤال من الاختبار النهائي
            </AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من إزالة هذا السؤال من الاختبار النهائي؟ لن يتم حذفه
              من بنك الأسئلة.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleRemoveFromQuiz}>
              إزالة
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
