"use client"

import { QuestionFormDialog } from "@/components/forms/question-form-dialog"
import { QuestionsGrid } from "@/components/questions-grid"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
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
import { Input } from "@/components/ui/input"
import { createPracticeQuizAction } from "@/lib/actions/practice-quizzes"
import type { PracticeQuizResponse, QuestionResponse } from "@/lib/api/types"
import { ClipboardList, Plus, X } from "lucide-react"
import { useRouter } from "next/navigation"
import { useState } from "react"
import { toast } from "sonner"

interface QuizzesClientProps {
  courseId: number
  orgSlug: string
  courseSlug: string
  courseTitle: string
  initialQuizzes: PracticeQuizResponse[]
  initialBankQuestions: QuestionResponse[]
}

export function QuizzesClient({
  courseId,
  orgSlug,
  courseSlug,
  initialQuizzes,
  initialBankQuestions,
}: QuizzesClientProps) {
  const router = useRouter()
  const [quizzes, setQuizzes] = useState(initialQuizzes)
  const [bankQuestions, setBankQuestions] = useState(initialBankQuestions)
  const [createOpen, setCreateOpen] = useState(false)
  const [title, setTitle] = useState("")
  const [description, setDescription] = useState("")
  const [creating, setCreating] = useState(false)
  const [selectedQuestions, setSelectedQuestions] = useState<
    QuestionResponse[]
  >([])

  // add new question dialog
  const [creatingQuestion, setCreatingQuestion] = useState(false)

  // add from bank dialog
  const [selectFromBankOpen, setSelectFromBankOpen] = useState(false)

  const selectedIds = new Set(selectedQuestions.map((q) => q.id))
  const availableBankQuestions = bankQuestions.filter(
    (q) => !selectedIds.has(q.id)
  )

  function handleCreateQuestionSaved(question: QuestionResponse) {
    setBankQuestions((prev) => {
      const exists = prev.findIndex((q) => q.id === question.id)
      if (exists >= 0) {
        return prev.map((q) => (q.id === question.id ? question : q))
      }
      return [...prev, question]
    })
    setSelectedQuestions((prev) => [...prev, question])
    setCreatingQuestion(false)
  }

  function handleAddFromBank(question: QuestionResponse) {
    setSelectedQuestions((prev) => [...prev, question])
    setSelectFromBankOpen(false)
  }

  function handleRemoveSelected(question: QuestionResponse) {
    setSelectedQuestions((prev) => prev.filter((q) => q.id !== question.id))
  }

  async function handleCreate() {
    if (!title.trim()) {
      toast.error("عنوان الاختبار مطلوب")
      return
    }
    if (selectedQuestions.length === 0) {
      toast.error("يجب إضافة سؤال واحد على الأقل")
      return
    }

    setCreating(true)
    const result = await createPracticeQuizAction(
      courseId,
      {
        title: title.trim(),
        description: description.trim() || undefined,
        questionIds: selectedQuestions.map((q) => q.id),
      },
      orgSlug,
      courseSlug
    )
    setCreating(false)

    if (result.error) {
      toast.error(result.error)
      return
    }

    if (result.quiz) {
      setQuizzes((prev) => [...prev, result.quiz!])
      setCreateOpen(false)
      setTitle("")
      setDescription("")
      setSelectedQuestions([])
      router.push(`/${orgSlug}/courses/${courseSlug}/quizzes/${result.quiz.id}`)
    }
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">الاختبارات</h2>
        <Button
          onClick={() => {
            setTitle("")
            setDescription("")
            setSelectedQuestions([])
            setCreatingQuestion(false)
            setSelectFromBankOpen(false)
            setCreateOpen(true)
          }}
        >
          <Plus />
          إضافة اختبار
        </Button>
      </div>

      {quizzes.length === 0 ? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <ClipboardList />
            </EmptyMedia>
            <EmptyTitle>لا توجد اختبارات</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>
            لم يتم إضافة اختبارات لهذه الدورة بعد. أضف اختباراً جديداً للبدء.
          </EmptyContent>
        </Empty>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {quizzes.map((quiz) => (
            <div
              key={quiz.id}
              role="button"
              tabIndex={0}
              className="cursor-pointer rounded-2xl border border-border bg-card p-4 transition-colors hover:bg-accent/50"
              onClick={() =>
                router.push(
                  `/${orgSlug}/courses/${courseSlug}/quizzes/${quiz.id}`
                )
              }
              onKeyDown={(e) => {
                if (e.key === "Enter")
                  router.push(
                    `/${orgSlug}/courses/${courseSlug}/quizzes/${quiz.id}`
                  )
              }}
            >
              <h3 className="font-medium">{quiz.title}</h3>
              {quiz.description && (
                <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">
                  {quiz.description}
                </p>
              )}
              <p className="mt-2 text-xs text-muted-foreground">
                {quiz.questions.length} أسئلة
              </p>
            </div>
          ))}
        </div>
      )}

      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-h-[90dvh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>إضافة اختبار جديد</DialogTitle>
          </DialogHeader>
          <div className="flex flex-col gap-4">
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="عنوان الاختبار"
            />
            <Input
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="وصف (اختياري)"
            />

            <div className="flex flex-col gap-2">
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-medium">الأسئلة</h3>
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setSelectFromBankOpen(true)}
                    disabled={bankQuestions.length === 0}
                  >
                    <Plus />
                    من بنك الأسئلة
                  </Button>
                  <Button
                    size="icon-sm"
                    onClick={() => setCreatingQuestion(true)}
                  >
                    <Plus />
                  </Button>
                </div>
              </div>

              {selectedQuestions.length === 0 ? (
                <p className="text-xs text-muted-foreground">
                  لم يتم إضافة أسئلة. يجب إضافة سؤال واحد على الأقل.
                </p>
              ) : (
                <div className="flex flex-col gap-1">
                  {selectedQuestions.map((q) => (
                    <div
                      key={q.id}
                      className="flex items-center justify-between rounded-xl border border-border bg-card p-2 text-sm"
                    >
                      <span className="line-clamp-1 flex-1">{q.content}</span>
                      <Button
                        variant="ghost"
                        size="icon-xs"
                        onClick={() => handleRemoveSelected(q)}
                      >
                        <X className="size-3" />
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <Button
              onClick={handleCreate}
              disabled={creating || selectedQuestions.length === 0}
            >
              {creating ? "جاري الإنشاء..." : "إنشاء الاختبار"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <QuestionFormDialog
        key={creatingQuestion ? "create-in-list" : "idle"}
        open={creatingQuestion}
        onOpenChange={(open) => {
          if (!open) setCreatingQuestion(false)
        }}
        question={null}
        courseId={courseId}
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={handleCreateQuestionSaved}
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
    </div>
  )
}
