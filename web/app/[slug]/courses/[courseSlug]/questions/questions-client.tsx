"use client"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { QuestionFormDialog } from "@/components/forms/question-form-dialog"
import { QuestionBank } from "@/components/question-bank"
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
import { deleteQuestionAction } from "@/lib/actions/course"
import type { QuestionResponse } from "@/lib/api/types"
import { Plus } from "lucide-react"
import { useState } from "react"
import { toast } from "sonner"

interface QuestionsPageClientProps {
  courseId: number
  orgSlug: string
  courseSlug: string
  courseTitle: string
  initialQuestions: QuestionResponse[]
}

export function QuestionsPageClient({
  courseId,
  orgSlug,
  courseSlug,
  courseTitle,
  initialQuestions,
}: QuestionsPageClientProps) {
  const [questions, setQuestions] =
    useState<QuestionResponse[]>(initialQuestions)
  const [editingQuestion, setEditingQuestion] =
    useState<QuestionResponse | null>(null)
  const [creating, setCreating] = useState(false)
  const [deletingQuestion, setDeletingQuestion] =
    useState<QuestionResponse | null>(null)

  async function handleDelete() {
    const q = deletingQuestion
    if (!q) return
    setDeletingQuestion(null)
    setQuestions((prev) => prev.filter((x) => x.id !== q.id))

    const result = await deleteQuestionAction(q.id, orgSlug, courseSlug)
    if (result.error) {
      if (result.conflict) {
        toast.error(result.error, { duration: 6000 })
      } else {
        toast.error(result.error)
      }
      setQuestions((prev) => [...prev, q])
      return
    }
    toast.success("تم حذف السؤال بنجاح")
  }

  function handleSaved(question: QuestionResponse) {
    setQuestions((prev) => {
      const exists = prev.findIndex((q) => q.id === question.id)
      if (exists >= 0) {
        return prev.map((q) => (q.id === question.id ? question : q))
      }
      return [...prev, question]
    })
  }

  return (
    <div className="flex flex-col gap-4">
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${orgSlug}/courses` },
          { label: courseTitle, href: `/${orgSlug}/courses/${courseSlug}` },
          { label: "بنك الأسئلة" },
        ]}
      />

      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">بنك الأسئلة</h2>
        <Button onClick={() => setCreating(true)}>
          <Plus />
          إضافة سؤال
        </Button>
      </div>

      <QuestionBank
        questions={questions}
        mode="edit"
        onEdit={(q) => setEditingQuestion(q)}
        onDelete={(q) => setDeletingQuestion(q)}
      />

      <QuestionFormDialog
        key={creating ? "create" : (editingQuestion?.id ?? "idle")}
        open={creating || !!editingQuestion}
        onOpenChange={(open) => {
          if (!open) {
            setCreating(false)
            setEditingQuestion(null)
          }
        }}
        question={editingQuestion}
        courseId={courseId}
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={handleSaved}
      />

      <AlertDialog
        open={!!deletingQuestion}
        onOpenChange={(open) => {
          if (!open) setDeletingQuestion(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف السؤال</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذا السؤال؟ لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>حذف</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
