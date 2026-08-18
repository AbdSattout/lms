"use client"

import { QuestionFormDialog } from "@/components/forms/question-form-dialog"
import { QuestionsGrid } from "@/components/questions-grid"
import { Badge } from "@/components/ui/badge"
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
import { createPracticeExamAction } from "@/lib/actions/practice-exams"
import { createPracticeQuizAction } from "@/lib/actions/practice-quizzes"
import type {
  CourseResponse,
  PracticeExamResponse,
  PracticeQuizResponse,
  QuestionResponse,
} from "@/lib/api/types"
import { ClipboardList, FileQuestion, Plus, Timer, X } from "lucide-react"
import { useRouter } from "next/navigation"
import { useState } from "react"
import { toast } from "sonner"

interface QuizzesClientProps {
  course: CourseResponse
  orgSlug: string
  initialExams: PracticeExamResponse[]
  initialQuizzes: PracticeQuizResponse[]
  initialBankQuestions: QuestionResponse[]
}

export function QuizzesClient({
  course,
  orgSlug,
  initialExams,
  initialQuizzes,
  initialBankQuestions,
}: QuizzesClientProps) {
  const courseId = course.id
  const courseSlug = course.slug
  const router = useRouter()
  const [exams, setExams] = useState(initialExams)
  const [quizzes, setQuizzes] = useState(initialQuizzes)
  const [bankQuestions, setBankQuestions] = useState(initialBankQuestions)

  // create exam dialog
  const [createExamOpen, setCreateExamOpen] = useState(false)
  const [examTitle, setExamTitle] = useState("")
  const [examDescription, setExamDescription] = useState("")
  const [examTimeLimit, setExamTimeLimit] = useState("")
  const [creatingExam, setCreatingExam] = useState(false)

  // create quiz dialog
  const [createQuizOpen, setCreateQuizOpen] = useState(false)
  const [quizTitle, setQuizTitle] = useState("")
  const [quizDescription, setQuizDescription] = useState("")
  const [creatingQuiz, setCreatingQuiz] = useState(false)

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

  async function handleCreateExam() {
    if (!examTitle.trim()) {
      toast.error("عنوان الامتحان مطلوب")
      return
    }
    if (selectedQuestions.length === 0) {
      toast.error("يجب إضافة سؤال واحد على الأقل")
      return
    }

    let timeLimitMinutes: number | undefined
    if (examTimeLimit.trim()) {
      timeLimitMinutes = Number(examTimeLimit.trim())
      if (!Number.isInteger(timeLimitMinutes) || timeLimitMinutes <= 0) {
        toast.error("الوقت يجب أن يكون رقماً صحيحاً أكبر من صفر")
        return
      }
    }

    setCreatingExam(true)
    const result = await createPracticeExamAction(
      courseId,
      {
        title: examTitle.trim(),
        description: examDescription.trim() || undefined,
        timeLimitMinutes,
        questionIds: selectedQuestions.map((q) => q.id),
      },
      orgSlug,
      courseSlug
    )
    setCreatingExam(false)

    if (result.error) {
      toast.error(result.error)
      return
    }

    if (result.exam) {
      setExams((prev) => [...prev, result.exam!])
      setCreateExamOpen(false)
      setExamTitle("")
      setExamDescription("")
      setExamTimeLimit("")
      setSelectedQuestions([])
      router.push(
        `/${orgSlug}/courses/${courseSlug}/quizzes/exams/${result.exam.id}`
      )
    }
  }

  async function handleCreateQuiz() {
    if (!quizTitle.trim()) {
      toast.error("عنوان الاختبار مطلوب")
      return
    }
    if (selectedQuestions.length === 0) {
      toast.error("يجب إضافة سؤال واحد على الأقل")
      return
    }

    setCreatingQuiz(true)
    const result = await createPracticeQuizAction(
      courseId,
      {
        title: quizTitle.trim(),
        description: quizDescription.trim() || undefined,
        questionIds: selectedQuestions.map((q) => q.id),
      },
      orgSlug,
      courseSlug
    )
    setCreatingQuiz(false)

    if (result.error) {
      toast.error(result.error)
      return
    }

    if (result.quiz) {
      setQuizzes((prev) => [...prev, result.quiz!])
      setCreateQuizOpen(false)
      setQuizTitle("")
      setQuizDescription("")
      setSelectedQuestions([])
      router.push(`/${orgSlug}/courses/${courseSlug}/quizzes/${result.quiz.id}`)
    }
  }

  function resetQuestionPicker() {
    setSelectedQuestions([])
    setCreatingQuestion(false)
    setSelectFromBankOpen(false)
  }

  const questionPicker = (
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
          <Button size="icon-sm" onClick={() => setCreatingQuestion(true)}>
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
  )

  return (
    <div className="flex flex-col gap-8">
      {/* ===== امتحانات ===== */}
      <section className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold">امتحانات</h2>
          <Button
            onClick={() => {
              setExamTitle("")
              setExamDescription("")
              setExamTimeLimit("")
              resetQuestionPicker()
              setCreateExamOpen(true)
            }}
          >
            <Plus />
            إضافة امتحان
          </Button>
        </div>

        {exams.length === 0 ? (
          <Empty>
            <EmptyHeader>
              <EmptyMedia variant="icon">
                <ClipboardList />
              </EmptyMedia>
              <EmptyTitle>لا توجد امتحانات</EmptyTitle>
            </EmptyHeader>
            <EmptyContent>
              لم يتم إضافة امتحانات لهذه الدورة بعد. أضف امتحاناً جديداً للبدء.
            </EmptyContent>
          </Empty>
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {exams.map((exam) => (
              <div
                key={exam.id}
                role="button"
                tabIndex={0}
                className="cursor-pointer rounded-2xl border border-border bg-card p-4 transition-colors hover:bg-accent/50"
                onClick={() =>
                  router.push(
                    `/${orgSlug}/courses/${courseSlug}/quizzes/exams/${exam.id}`
                  )
                }
                onKeyDown={(e) => {
                  if (e.key === "Enter")
                    router.push(
                      `/${orgSlug}/courses/${courseSlug}/quizzes/exams/${exam.id}`
                    )
                }}
              >
                <div className="flex items-start justify-between gap-2">
                  <h3 className="font-medium">{exam.title}</h3>
                  <Badge
                    variant={
                      exam.status === "PUBLISHED" ? "default" : "secondary"
                    }
                  >
                    {exam.status === "PUBLISHED" ? "منشور" : "مسودة"}
                  </Badge>
                </div>
                {exam.description && (
                  <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">
                    {exam.description}
                  </p>
                )}
                <div className="mt-2 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
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
            ))}
          </div>
        )}
      </section>

      {/* ===== اختبارات ===== */}
      <section className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold">الاختبارات</h2>
          <Button
            onClick={() => {
              setQuizTitle("")
              setQuizDescription("")
              resetQuestionPicker()
              setCreateQuizOpen(true)
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
                <p className="mt-2 flex items-center gap-1 text-xs text-muted-foreground">
                  <FileQuestion className="size-3" />
                  {quiz.questions.length} أسئلة
                </p>
              </div>
            ))}
          </div>
        )}
      </section>

      <Dialog open={createExamOpen} onOpenChange={setCreateExamOpen}>
        <DialogContent className="max-h-[90dvh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>إضافة امتحان جديد</DialogTitle>
          </DialogHeader>
          <div className="flex flex-col gap-4">
            <Input
              value={examTitle}
              onChange={(e) => setExamTitle(e.target.value)}
              placeholder="عنوان الامتحان"
            />
            <Input
              value={examDescription}
              onChange={(e) => setExamDescription(e.target.value)}
              placeholder="وصف (اختياري)"
            />
            <Input
              type="number"
              min={1}
              value={examTimeLimit}
              onChange={(e) => setExamTimeLimit(e.target.value)}
              placeholder="الوقت بالدقائق (اختياري)"
            />

            {questionPicker}

            <Button
              onClick={handleCreateExam}
              disabled={creatingExam || selectedQuestions.length === 0}
            >
              {creatingExam ? "جاري الإنشاء..." : "إنشاء الامتحان"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={createQuizOpen} onOpenChange={setCreateQuizOpen}>
        <DialogContent className="max-h-[90dvh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>إضافة اختبار جديد</DialogTitle>
          </DialogHeader>
          <div className="flex flex-col gap-4">
            <Input
              value={quizTitle}
              onChange={(e) => setQuizTitle(e.target.value)}
              placeholder="عنوان الاختبار"
            />
            <Input
              value={quizDescription}
              onChange={(e) => setQuizDescription(e.target.value)}
              placeholder="وصف (اختياري)"
            />

            {questionPicker}

            <Button
              onClick={handleCreateQuiz}
              disabled={creatingQuiz || selectedQuestions.length === 0}
            >
              {creatingQuiz ? "جاري الإنشاء..." : "إنشاء الاختبار"}
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
        course={course}
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
