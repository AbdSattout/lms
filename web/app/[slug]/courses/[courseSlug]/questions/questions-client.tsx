"use client"

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { Editor } from "@/components/editor"
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
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  createQuestionAction,
  deleteQuestionAction,
  updateQuestionAction,
} from "@/lib/actions/course"
import type { QuestionResponse } from "@/lib/api/types"
import { Plus } from "lucide-react"
import { useEffect, useRef, useState } from "react"
import { toast } from "sonner"

function QuestionDialog({
  open,
  onOpenChange,
  question,
  courseId,
  orgSlug,
  courseSlug,
  onSaved,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  question: QuestionResponse | null
  courseId: number
  orgSlug: string
  courseSlug: string
  onSaved: (question: QuestionResponse) => void
}) {
  const isEdit = !!question
  const [content, setContent] = useState(question?.content ?? "")
  const [options, setOptions] = useState<string[]>(question?.options ?? [])
  const [correctIndex, setCorrectIndex] = useState(
    question?.correctAnswerIndex ?? 0
  )
  const [newOption, setNewOption] = useState("")
  const [saving, setSaving] = useState(false)
  const [confirmClose, setConfirmClose] = useState(false)
  const dirtyRef = useRef(false)

  useEffect(() => {
    dirtyRef.current = false
  }, [question, open])

  useEffect(() => {
    if (dirtyRef.current) return
    if (isEdit) {
      const orig = question!
      const contentChanged = content !== orig.content
      const optionsChanged =
        options.join("\0") !== (orig.options ?? []).join("\0")
      const indexChanged = correctIndex !== orig.correctAnswerIndex
      const hasNew = newOption.trim().length > 0
      dirtyRef.current =
        contentChanged || optionsChanged || indexChanged || hasNew
    } else {
      dirtyRef.current =
        content.trim().length > 0 ||
        options.length > 0 ||
        newOption.trim().length > 0
    }
  }, [content, options, correctIndex, newOption, isEdit, question])

  function addOption() {
    const trimmed = newOption.trim()
    if (!trimmed) return
    setOptions((prev) => [...prev, trimmed])
    setNewOption("")
  }

  function handleOptionBlur(index: number, value: string) {
    if (value !== "" || options.length <= 2) return
    setOptions((prev) => prev.filter((_, i) => i !== index))
    setCorrectIndex((prev) => {
      if (prev === index) return 0
      if (prev > index) return prev - 1
      return prev
    })
  }

  function handleClose() {
    if (dirtyRef.current) {
      setConfirmClose(true)
    } else {
      onOpenChange(false)
    }
  }

  async function handleSave() {
    if (!content.trim()) {
      toast.error("محتوى السؤال مطلوب")
      return
    }

    const allOptions = newOption.trim()
      ? [...options, newOption.trim()]
      : options

    if (allOptions.length < 2) {
      toast.error("يجب توفير خيارين على الأقل")
      return
    }

    if (correctIndex >= allOptions.length) {
      toast.error("الرجاء تحديد الإجابة الصحيحة")
      return
    }

    setSaving(true)

    const data = {
      content: content.trim(),
      options: allOptions,
      correctAnswerIndex: correctIndex,
    }

    let result: { error?: string; question?: QuestionResponse }

    if (isEdit) {
      result = await updateQuestionAction(
        question.id,
        data,
        orgSlug,
        courseSlug
      )
    } else {
      result = await createQuestionAction(courseId, data, orgSlug, courseSlug)
    }

    if (result.error) {
      toast.error(result.error)
      setSaving(false)
      return
    }

    toast.success(isEdit ? "تم تحديث السؤال بنجاح" : "تم إنشاء السؤال بنجاح")
    setSaving(false)
    if (result.question) onSaved(result.question)
    onOpenChange(false)
  }

  return (
    <>
      <Dialog open={open} onOpenChange={handleClose}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>
              {isEdit ? "تعديل السؤال" : "إضافة سؤال جديد"}
            </DialogTitle>
          </DialogHeader>

          <div className="flex max-h-[60dvh] flex-col gap-4 overflow-y-auto">
            <div className="flex min-h-48 flex-col overflow-hidden rounded-2xl border">
              <Editor
                key={question?.id ?? "new"}
                content={content ?? ""}
                onChange={setContent}
              />
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium">الإجابات</label>
              <div className="flex flex-col gap-2">
                {options.map((option, index) => (
                  <div
                    key={index}
                    className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
                      index === correctIndex
                        ? "border-primary bg-primary/5"
                        : "border-border bg-card"
                    }`}
                    onClick={() => setCorrectIndex(index)}
                  >
                    <input
                      value={option}
                      onChange={(e) =>
                        setOptions((prev) =>
                          prev.map((opt, i) =>
                            i === index ? e.target.value : opt
                          )
                        )
                      }
                      onBlur={(e) => handleOptionBlur(index, e.target.value)}
                      placeholder={`الإجابة ${index + 1}`}
                      className="h-7 flex-1 rounded-none border-none bg-transparent px-0 text-sm shadow-none outline-none placeholder:text-muted-foreground"
                      onClick={(e) => e.stopPropagation()}
                    />
                  </div>
                ))}
                <div className="flex items-center gap-2 rounded-xl border border-dashed border-border bg-transparent p-3">
                  <input
                    value={newOption}
                    onChange={(e) => setNewOption(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault()
                        addOption()
                      }
                    }}
                    onBlur={addOption}
                    placeholder="إضافة إجابة جديدة..."
                    className="h-7 flex-1 rounded-none border-none bg-transparent px-0 text-sm shadow-none outline-none placeholder:text-muted-foreground"
                  />
                  <Plus className="size-4 shrink-0 text-muted-foreground" />
                </div>
              </div>
            </div>

            <Button onClick={handleSave} disabled={saving} className="w-full">
              {saving
                ? "جاري الحفظ..."
                : isEdit
                  ? "حفظ التغييرات"
                  : "إضافة السؤال"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <AlertDialog open={confirmClose} onOpenChange={setConfirmClose}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>تجاهل التغييرات؟</AlertDialogTitle>
            <AlertDialogDescription>
              لديك تغييرات غير محفوظة. هل تريد تجاهلها؟
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                setConfirmClose(false)
                onOpenChange(false)
              }}
            >
              تجاهل
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}

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

      <QuestionDialog
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
