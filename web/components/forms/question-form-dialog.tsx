"use client"

import { Editor } from "@/components/editor"
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
  updateQuestionAction,
} from "@/lib/actions/course"
import type { CourseResponse, QuestionDifficulty, QuestionResponse } from "@/lib/api/types"
import {
  DndContext,
  DragOverlay,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
  type DragStartEvent,
} from "@dnd-kit/core"
import {
  arrayMove,
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable"
import { CSS } from "@dnd-kit/utilities"
import { GripVertical, Plus } from "lucide-react"
import { useEffect, useRef, useState } from "react"
import { createPortal } from "react-dom"
import { toast } from "sonner"

interface OptionItem {
  id: string
  text: string
}

let optionCounter = 0
function createOptionItem(text: string): OptionItem {
  return { id: `opt_${++optionCounter}`, text }
}
function toOptionItems(strings: string[]): OptionItem[] {
  return strings.map((s) => createOptionItem(s))
}
function toOptionStrings(items: OptionItem[]): string[] {
  return items.map((o) => o.text)
}

interface QuestionFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  question: QuestionResponse | null
  courseId: number
  course: CourseResponse
  orgSlug: string
  courseSlug: string
  onSaved: (question: QuestionResponse) => void
}

function SortableOption({
  option,
  isCorrect,
  onSelect,
  onChange,
  onBlur,
  placeholder,
}: {
  option: OptionItem
  isCorrect: boolean
  onSelect: () => void
  onChange: (value: string) => void
  onBlur: () => void
  placeholder: string
}) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: option.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  const inputRef = useRef<HTMLInputElement>(null)

  return (
    <div
      ref={setNodeRef}
      style={style}
      onDoubleClick={onSelect}
      className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
        isDragging ? "z-50 opacity-50" : ""
      } ${isCorrect ? "border-primary bg-primary/5" : "border-border bg-card"}`}
    >
      <button
        className="touch-none text-muted-foreground hover:text-foreground"
        onClick={(e) => e.stopPropagation()}
        {...attributes}
        {...listeners}
      >
        <GripVertical className="size-4" />
      </button>
      <input
        ref={inputRef}
        value={option.text}
        onChange={(e) => onChange(e.target.value)}
        onBlur={onBlur}
        placeholder={placeholder}
        onClick={() => inputRef.current?.focus()}
        className="h-7 flex-1 rounded-none border-none bg-transparent px-0 text-sm shadow-none outline-none placeholder:text-muted-foreground"
      />
    </div>
  )
}

export function QuestionFormDialog({
  open,
  onOpenChange,
  question,
  courseId,
  course,
  orgSlug,
  courseSlug,
  onSaved,
}: QuestionFormDialogProps) {
  const isEdit = !!question
  const [content, setContent] = useState(question?.content ?? "")
  const [options, setOptions] = useState<OptionItem[]>(() =>
    toOptionItems(question?.options ?? [])
  )
  const [correctIndex, setCorrectIndex] = useState(
    question?.correctAnswerIndex ?? 0
  )
  const [difficulty, setDifficulty] = useState<QuestionDifficulty>(
    question?.difficulty ?? "EASY"
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
        toOptionStrings(options).join("\0") !== (orig.options ?? []).join("\0")
      const indexChanged = correctIndex !== orig.correctAnswerIndex
      const difficultyChanged = difficulty !== orig.difficulty
      const hasNew = newOption.trim().length > 0
      dirtyRef.current =
        contentChanged ||
        optionsChanged ||
        indexChanged ||
        difficultyChanged ||
        hasNew
    } else {
      dirtyRef.current =
        content.trim().length > 0 ||
        options.length > 0 ||
        newOption.trim().length > 0
    }
  }, [content, options, correctIndex, difficulty, newOption, isEdit, question])

  const [activeOptionId, setActiveOptionId] = useState<string | null>(null)

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 8 } }),
    useSensor(KeyboardSensor)
  )

  function handleOptionDragStart(event: DragStartEvent) {
    setActiveOptionId(event.active.id as string)
  }

  function handleOptionDragEnd(event: DragEndEvent) {
    const { active, over } = event
    setActiveOptionId(null)
    if (!over || active.id === over.id) return

    const activeIndex = options.findIndex((o) => o.id === active.id)
    const overIndex = options.findIndex((o) => o.id === over.id)

    setOptions((prev) => arrayMove(prev, activeIndex, overIndex))
    setCorrectIndex((prev) => {
      if (prev === activeIndex) return overIndex
      if (activeIndex < overIndex && prev > activeIndex && prev <= overIndex)
        return prev - 1
      if (activeIndex > overIndex && prev < activeIndex && prev >= overIndex)
        return prev + 1
      return prev
    })
  }

  function addOption() {
    const trimmed = newOption.trim()
    if (!trimmed) return
    setOptions((prev) => [...prev, createOptionItem(trimmed)])
    setNewOption("")
  }

  function handleOptionBlur(id: string) {
    setOptions((prev) => {
      const item = prev.find((o) => o.id === id)
      if (!item || item.text !== "" || prev.length <= 2) return prev
      const index = prev.findIndex((o) => o.id === id)
      setCorrectIndex((ci) => {
        if (ci === index) return 0
        if (ci > index) return ci - 1
        return ci
      })
      return prev.filter((o) => o.id !== id)
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

    const allOptionStrings = newOption.trim()
      ? [...toOptionStrings(options), newOption.trim()]
      : toOptionStrings(options)

    if (allOptionStrings.length < 2) {
      toast.error("يجب توفير خيارين على الأقل")
      return
    }

    if (correctIndex >= allOptionStrings.length) {
      toast.error("الرجاء تحديد الإجابة الصحيحة")
      return
    }

    setSaving(true)

    const data = {
      content: content.trim(),
      options: allOptionStrings,
      correctAnswerIndex: correctIndex,
      difficulty,
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
                key={question?.id ?? "new-question"}
                content={content ?? ""}
                onChange={setContent}
                orgSlug={orgSlug}
                course={course}
              />
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium">مستوى الصعوبة</label>
              <div className="flex w-full overflow-hidden rounded-full border border-border">
                {(["EASY", "MEDIUM", "HARD"] as const).map((level) => (
                  <button
                    key={level}
                    type="button"
                    onClick={() => setDifficulty(level)}
                    className={`flex-1 cursor-pointer rounded-full px-3 py-2 text-sm font-medium transition-colors ${
                      difficulty === level
                        ? "bg-primary text-primary-foreground"
                        : "text-muted-foreground hover:bg-accent"
                    }`}
                  >
                    {level === "EASY"
                      ? "سهل"
                      : level === "MEDIUM"
                        ? "متوسط"
                        : "صعب"}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium">الإجابات</label>
              <p className="text-xs text-muted-foreground">
                انقر نقرًا مزدوجًا لتحديد الإجابة الصحيحة
              </p>
              <DndContext
                sensors={sensors}
                onDragStart={handleOptionDragStart}
                onDragEnd={handleOptionDragEnd}
              >
                <SortableContext
                  items={options.map((o) => o.id)}
                  strategy={verticalListSortingStrategy}
                >
                  <div className="flex flex-col gap-2">
                    {options.map((option, index) => (
                      <SortableOption
                        key={option.id}
                        option={option}
                        isCorrect={index === correctIndex}
                        onSelect={() => setCorrectIndex(index)}
                        onChange={(value) =>
                          setOptions((prev) =>
                            prev.map((opt) =>
                              opt.id === option.id
                                ? { ...opt, text: value }
                                : opt
                            )
                          )
                        }
                        onBlur={() => handleOptionBlur(option.id)}
                        placeholder={`الإجابة ${index + 1}`}
                      />
                    ))}
                  </div>
                </SortableContext>
                {typeof document !== "undefined" &&
                  createPortal(
                    <DragOverlay dropAnimation={null}>
                      {activeOptionId !== null && (
                        <div className="flex items-center gap-2 rounded-xl border border-border bg-card p-3 shadow-lg">
                          <GripVertical className="size-4 text-muted-foreground" />
                          <span className="truncate text-sm">
                            {options.find((o) => o.id === activeOptionId)
                              ?.text ?? ""}
                          </span>
                        </div>
                      )}
                    </DragOverlay>,
                    document.body
                  )}
              </DndContext>
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

            <Button
              onClick={handleSave}
              disabled={saving}
              className="w-full cursor-pointer"
            >
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
