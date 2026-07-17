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
  deletePracticeQuizAction,
  updatePracticeQuizQuestionsAction,
} from "@/lib/actions/practice-quizzes"
import type { PracticeQuizResponse, QuestionResponse } from "@/lib/api/types"
import { Plus, Trash2 } from "lucide-react"
import { useState } from "react"
import { toast } from "sonner"

interface QuizDetailClientProps {
  courseId: number
  orgSlug: string
  courseSlug: string
  quiz: PracticeQuizResponse
  bankQuestions: QuestionResponse[]
}

export function QuizDetailClient({
  courseId,
  orgSlug,
  courseSlug,
  quiz: initialQuiz,
  bankQuestions: initialBankQuestions,
}: QuizDetailClientProps) {
  const [quiz, setQuiz] = useState(initialQuiz)
  const [bankQuestions, setBankQuestions] = useState(initialBankQuestions)

  // Add new question dialog
  const [creatingQuestion, setCreatingQuestion] = useState(false)
  const [editingQuestion, setEditingQuestion] =
    useState<QuestionResponse | null>(null)

  // Add from bank dialog
  const [selectFromBankOpen, setSelectFromBankOpen] = useState(false)

  // Remove confirmation
  const [removingQuestion, setRemovingQuestion] =
    useState<QuestionResponse | null>(null)

  // Delete quiz
  const [deletingQuiz, setDeletingQuiz] = useState(false)

  async function handleDeleteQuiz() {
    setDeletingQuiz(true)
    const result = await deletePracticeQuizAction(
      courseId,
      quiz.id,
      orgSlug,
      courseSlug
    )
    if (result.error) {
      toast.error(result.error)
      setDeletingQuiz(false)
    }
  }

  const quizQuestionIds = new Set(quiz.questions.map((q) => q.id))
  const availableBankQuestions = bankQuestions.filter(
    (q) => !quizQuestionIds.has(q.id)
  )

  async function syncQuestions(newQuestions: QuestionResponse[]) {
    const questionIds = newQuestions.map((q) => q.id)
    const result = await updatePracticeQuizQuestionsAction(
      courseId,
      quiz.id,
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

    const newQuestions = [...quiz.questions, question]
    const ok = await syncQuestions(newQuestions)
    if (!ok) {
      setBankQuestions((prev) => prev.filter((q) => q.id !== question.id))
    }
  }

  async function handleAddFromBank(question: QuestionResponse) {
    const newQuestions = [...quiz.questions, question]
    const ok = await syncQuestions(newQuestions)
    if (ok) {
      setSelectFromBankOpen(false)
      toast.success("تمت إضافة السؤال إلى الاختبار")
    }
  }

  async function handleRemoveFromQuiz() {
    const q = removingQuestion
    if (!q) return
    setRemovingQuestion(null)

    const newQuestions = quiz.questions.filter((x) => x.id !== q.id)

    if (newQuestions.length === 0) {
      toast.error("يجب أن يحتوي الاختبار على سؤال واحد على الأقل")
      return
    }

    await syncQuestions(newQuestions)
    toast.success("تمت إزالة السؤال من الاختبار")
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">{quiz.title}</h2>
          {quiz.description && (
            <p className="text-sm text-muted-foreground">{quiz.description}</p>
          )}
          <p className="mt-1 text-xs text-muted-foreground">
            {quiz.questions.length} أسئلة
          </p>
        </div>
        <Button variant="destructive" onClick={() => setDeletingQuiz(true)}>
          <Trash2 />
          حذف الاختبار
        </Button>
      </div>

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

      <QuestionsGrid
        questions={quiz.questions}
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
            <DropdownMenuSeparator />
            <DropdownMenuItem
              variant="destructive"
              onClick={(e) => {
                e.stopPropagation()
                setRemovingQuestion(q)
              }}
            >
              <Trash2 />
              إزالة من الاختبار
            </DropdownMenuItem>
          </>
        )}
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
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={
          editingQuestion
            ? (q) => {
                setBankQuestions((prev) =>
                  prev.map((x) => (x.id === q.id ? q : x))
                )
                setQuiz((prev) => ({
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
            <AlertDialogTitle>إزالة السؤال من الاختبار</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من إزالة هذا السؤال من الاختبار؟ لن يتم حذفه من بنك
              الأسئلة.
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

      <AlertDialog
        open={deletingQuiz}
        onOpenChange={(open) => {
          if (!open) setDeletingQuiz(false)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الاختبار</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذا الاختبار؟ لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction variant="destructive" onClick={handleDeleteQuiz}>
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
