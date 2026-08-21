"use client"

import { QuestionCard } from "@/components/cards/question-card"
import { Editor } from "@/components/editor"
import { TiptapRenderer } from "@/components/editor/renderer"
import { QuestionFormDialog } from "@/components/forms/question-form-dialog"
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { Input } from "@/components/ui/input"
import {
  createBlockAction,
  deleteBlockAction,
  generateQuestionFromBlockContentAction,
  reorderBlocksAction,
  updateBlockAction,
} from "@/lib/actions/course"
import type {
  BlockResponse,
  CourseResponse,
  LessonDetailsResponse,
  LessonResponse,
  QuestionResponse,
} from "@/lib/api/types"
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
import {
  EllipsisVertical,
  FileQuestion,
  FileQuestionMark,
  FileText,
  GripVertical,
  Loader2,
  Pen,
  Plus,
  Save,
  Sparkles,
  Trash2,
} from "lucide-react"
import { useEffect, useRef, useState } from "react"
import { toast } from "sonner"

type SelectedId = number | "pending" | null

interface BlockTileProps {
  block: BlockResponse
  isSelected: boolean
  onSelect: () => void
  isPublished?: boolean
  onDelete?: () => void
  renaming?: boolean
  renamingTitle?: string
  onStartRename?: () => void
  onRenameChange?: (value: string) => void
  onCommitRename?: () => void
}

function BlockTile({
  block,
  isSelected,
  onSelect,
  isPublished,
  onDelete,
  renaming,
  renamingTitle,
  onStartRename,
  onRenameChange,
  onCommitRename,
}: BlockTileProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: `block:${block.id}`, disabled: isPublished })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  return (
    <div
      ref={setNodeRef}
      style={style}
      onClick={renaming ? undefined : onSelect}
      onDoubleClick={() => {
        if (isPublished) return
        if (renaming) return
        onStartRename?.()
      }}
      className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
        isDragging ? "z-50 opacity-50" : ""
      } ${
        isSelected ? "border-primary bg-primary/5" : "border-border bg-card"
      }`}
    >
      {!isPublished && (
        <button
          className="touch-none text-muted-foreground hover:text-foreground"
          onClick={(e) => e.stopPropagation()}
          {...attributes}
          {...listeners}
        >
          <GripVertical className="size-4" />
        </button>
      )}

      <div className="min-w-0 flex-1">
        {renaming ? (
          <Input
            value={renamingTitle}
            onChange={(e) => onRenameChange?.(e.target.value)}
            onBlur={onCommitRename}
            onKeyDown={(e) => {
              if (e.key === "Enter" || e.key === "Escape") onCommitRename?.()
            }}
            autoFocus
            className="h-6 px-2 text-sm"
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          <div className="truncate text-sm font-medium">{block.title}</div>
        )}
      </div>

      {!isPublished && (
        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            render={<Button variant="ghost" size="icon-xs" />}
          >
            <EllipsisVertical className="size-3" />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            {onStartRename && (
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation()
                  onStartRename()
                }}
              >
                <Pen />
                تعديل
              </DropdownMenuItem>
            )}
            <DropdownMenuSeparator />
            {onDelete && (
              <DropdownMenuItem
                variant="destructive"
                onClick={(e) => {
                  e.stopPropagation()
                  onDelete()
                }}
              >
                <Trash2 />
                حذف
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </div>
  )
}

interface PendingBlockTileProps {
  isSelected: boolean
  onSelect: () => void
  title: string
  renaming?: boolean
  renamingTitle?: string
  onStartRename?: () => void
  onRenameChange?: (value: string) => void
  onCommitRename?: () => void
}

function PendingBlockTile({
  isSelected,
  onSelect,
  title,
  renaming,
  renamingTitle,
  onStartRename,
  onRenameChange,
  onCommitRename,
}: PendingBlockTileProps) {
  return (
    <div
      onClick={renaming ? undefined : onSelect}
      onDoubleClick={() => onStartRename?.()}
      className={`flex cursor-pointer items-center gap-2 rounded-xl border border-dashed p-3 opacity-60 transition-colors ${
        isSelected ? "border-primary bg-primary/5" : "border-border bg-muted/30"
      }`}
    >
      <GripVertical className="size-4 shrink-0 text-muted-foreground/40" />
      <div className="min-w-0 flex-1">
        {renaming ? (
          <Input
            value={renamingTitle}
            onChange={(e) => onRenameChange?.(e.target.value)}
            onBlur={onCommitRename}
            onKeyDown={(e) => {
              if (e.key === "Enter" || e.key === "Escape") onCommitRename?.()
            }}
            className="h-6 px-2 text-sm"
            autoFocus
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          <div className="truncate text-sm font-medium text-muted-foreground/60">
            {title}
          </div>
        )}
      </div>
      <div className="size-6 shrink-0" />
    </div>
  )
}

interface BlockEditorPanelProps {
  block: BlockResponse | null
  isPending: boolean
  pendingContent: string
  orgSlug: string
  course: CourseResponse
  bankQuestions: QuestionResponse[]
  saving: boolean
  isPublished: boolean
  onSave: (content: string, questionId: number | null) => Promise<void>
  onCancelCreate: () => void
  onDirtyChange: (dirty: boolean) => void
}

function BlockEditorPanel({
  block,
  isPending,
  pendingContent,
  orgSlug,
  course,
  bankQuestions,
  saving,
  isPublished,
  onSave,
  onCancelCreate,
  onDirtyChange,
}: BlockEditorPanelProps) {
  const [editorContent, setEditorContent] = useState(
    isPending ? pendingContent : (block?.content ?? "")
  )
  const [questionId, setQuestionId] = useState<number | null>(
    isPending ? null : (block?.question?.id ?? null)
  )
  const [originalContent, setOriginalContent] = useState(
    isPending ? pendingContent : (block?.content ?? "")
  )
  const [originalQuestionId, setOriginalQuestionId] = useState<number | null>(
    isPending ? null : (block?.question?.id ?? null)
  )

  const [creatingQuestion, setCreatingQuestion] = useState(false)
  const [editingQuestion, setEditingQuestion] =
    useState<QuestionResponse | null>(null)
  const [selectFromBankOpen, setSelectFromBankOpen] = useState(false)
  const [removingQuestion, setRemovingQuestion] =
    useState<QuestionResponse | null>(null)
  const [localQuestions, setLocalQuestions] = useState<QuestionResponse[]>([])
  const [generating, setGenerating] = useState(false)

  const dirty =
    editorContent !== originalContent ||
    (questionId ?? null) !== (originalQuestionId ?? null)

  useEffect(() => {
    if (!isPublished) onDirtyChange(dirty)
  }, [dirty, onDirtyChange, isPublished])

  const courseSlug = course.slug

  const availableBankQuestions = bankQuestions.filter(
    (q) => q.id !== questionId
  )

  const currentQuestion =
    questionId === null
      ? null
      : (localQuestions.find((q) => q.id === questionId) ??
        (questionId === block?.question?.id && block.question.content?.trim()
          ? block.question
          : null) ??
        bankQuestions.find((q) => q.id === questionId) ??
        null)

  function handleEditorChange(md: string) {
    setEditorContent(md)
  }

  function handleRemoveQuestion() {
    setRemovingQuestion(null)
    setQuestionId(null)
    toast.success("تمت إزالة السؤال. احفظ التغييرات لتأكيد التعديل")
  }

  function handleQuestionSaved(question: QuestionResponse) {
    setQuestionId(question.id)
    setLocalQuestions((prev) => {
      const exists = prev.find((q) => q.id === question.id)
      if (exists) return prev.map((q) => (q.id === question.id ? question : q))
      return [...prev, question]
    })
    setCreatingQuestion(false)
    setEditingQuestion(null)
  }

  function handleAssignFromBank(question: QuestionResponse) {
    setQuestionId(question.id)
    setSelectFromBankOpen(false)
    toast.success("تم تعيين السؤال. احفظ التغييرات لتأكيد التعديل")
  }

  async function handleGenerateWithAI() {
    if (!editorContent.trim()) {
      toast.error("يجب كتابة محتوى الفقرة أولاً")
      return
    }
    setGenerating(true)
    const result = await generateQuestionFromBlockContentAction(
      course.id,
      editorContent,
      orgSlug,
      courseSlug
    )
    setGenerating(false)
    if (result.limitReached) {
      toast.error("لقد وصلت إلى الحد اليومي لأدوات الذكاء الاصطناعي.")
      return
    }
    if (result.error) {
      toast.error(result.error)
      return
    }
    if (result.question) {
      handleQuestionSaved(result.question)
      toast.success("تم توليد السؤال بنجاح")
    }
  }

  async function handleSave() {
    if (isPending) {
      if (!editorContent.trim()) {
        toast.error("محتوى الفقرة مطلوب")
        return
      }
      if (questionId === null) {
        toast.error("يجب اختيار سؤال للفقرة")
        return
      }
    }
    await onSave(editorContent, questionId)
    setOriginalContent(editorContent)
    setOriginalQuestionId(questionId ?? null)
  }

  if (isPublished) {
    return (
      <>
        <div className="flex flex-col gap-3">
          <h3 className="text-sm font-medium text-muted-foreground">
            محتوى الفقرة
          </h3>
          <div className="flex min-h-48 flex-col overflow-hidden rounded-2xl border p-4">
            <TiptapRenderer content={block?.content ?? ""} />
          </div>
        </div>

        <div className="flex flex-col gap-3">
          <h3 className="text-sm font-medium text-muted-foreground">السؤال</h3>
          {currentQuestion ? (
            <QuestionCard question={currentQuestion} />
          ) : (
            <div className="rounded-2xl border border-dashed border-border p-6 text-center text-sm text-muted-foreground">
              لا يوجد سؤال مرتبط بهذا الفقرة
            </div>
          )}
        </div>
      </>
    )
  }

  return (
    <>
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-medium text-muted-foreground">
            محتوى الفقرة
          </h3>
          <div className="flex items-center gap-2">
            {isPending && (
              <Button size="sm" variant="ghost" onClick={onCancelCreate}>
                إلغاء
              </Button>
            )}
            <Button
              size="sm"
              onClick={handleSave}
              disabled={!dirty || saving || questionId === null}
            >
              <Save />
              {saving ? "جاري الحفظ..." : isPending ? "إنشاء" : "حفظ"}
            </Button>
          </div>
        </div>

        <div className="flex min-h-48 flex-col overflow-hidden rounded-2xl border">
          <Editor
            content={editorContent}
            onChange={handleEditorChange}
            orgSlug={orgSlug}
            course={course}
          />
        </div>
      </div>

      <div className="flex flex-col gap-3">
        <h3 className="text-sm font-medium text-muted-foreground">السؤال</h3>

        {!currentQuestion ? (
          <Empty>
            <EmptyHeader>
              <EmptyMedia variant="icon">
                <FileQuestionMark />
              </EmptyMedia>
              <EmptyTitle>لم يتم إضافة سؤال بعد</EmptyTitle>
              <EmptyDescription>
                قم بإضافة سؤال جديد أو استخدم بنك الأسئلة.
              </EmptyDescription>
            </EmptyHeader>
            <EmptyContent className="flex-row justify-center gap-2">
              <Button
                onClick={
                  generating ? undefined : () => setCreatingQuestion(true)
                }
                disabled={generating}
              >
                {generating ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <Plus />
                )}
                {generating ? "جاري التوليد..." : "سؤال جديد"}
              </Button>
              <DropdownMenu>
                <DropdownMenuTrigger
                  render={
                    <Button
                      variant="outline"
                      size="icon"
                      disabled={generating}
                    />
                  }
                >
                  <EllipsisVertical />
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuItem
                    onClick={() => setSelectFromBankOpen(true)}
                    disabled={generating}
                  >
                    <FileQuestion />
                    من بنك الأسئلة
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    onClick={handleGenerateWithAI}
                    disabled={generating}
                  >
                    <Sparkles className="size-4" />
                    توليد بالذكاء الاصطناعي
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </EmptyContent>
          </Empty>
        ) : (
          <QuestionCard
            question={currentQuestion}
            onClick={(q) => setEditingQuestion(q)}
            renderActions={(q) => (
              <>
                <DropdownMenuItem
                  onClick={(e) => {
                    e.stopPropagation()
                    setEditingQuestion(q)
                  }}
                >
                  <Pen />
                  تعديل
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={(e) => {
                    e.stopPropagation()
                    setSelectFromBankOpen(true)
                  }}
                >
                  <FileQuestion />
                  استبدال من بنك الأسئلة
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
                  إزالة من الفقرة
                </DropdownMenuItem>
              </>
            )}
          />
        )}
      </div>

      <QuestionFormDialog
        key={
          creatingQuestion
            ? "create-lesson"
            : `edit-lesson-${editingQuestion?.id ?? "idle"}`
        }
        open={creatingQuestion || !!editingQuestion}
        onOpenChange={(open) => {
          if (!open) {
            setCreatingQuestion(false)
            setEditingQuestion(null)
          }
        }}
        question={editingQuestion}
        courseId={course.id}
        course={course}
        orgSlug={orgSlug}
        courseSlug={courseSlug}
        onSaved={handleQuestionSaved}
      />

      <Dialog open={selectFromBankOpen} onOpenChange={setSelectFromBankOpen}>
        <DialogContent className="max-h-[80dvh] max-w-4xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>اختر سؤالاً من بنك الأسئلة</DialogTitle>
          </DialogHeader>
          {availableBankQuestions.length === 0 ? (
            <Empty>
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <FileQuestion />
                </EmptyMedia>
                <EmptyTitle>لا توجد أسئلة متاحة</EmptyTitle>
                <EmptyDescription>
                  جميع أسئلة بنك الأسئلة مستخدمة بالفعل أو لا توجد أسئلة متاحة.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          ) : (
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              {availableBankQuestions.map((q) => (
                <QuestionCard
                  key={q.id}
                  question={q}
                  onClick={() => handleAssignFromBank(q)}
                />
              ))}
            </div>
          )}
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
            <AlertDialogTitle>إزالة السؤال من الفقرة</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من إزالة هذا السؤال من الفقرة؟ لن يتم حذفه من بنك
              الأسئلة.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleRemoveQuestion}>
              إزالة
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}

interface LessonEditorProps {
  lesson: LessonDetailsResponse | LessonResponse
  course: CourseResponse
  orgSlug: string
  initialBlocks: BlockResponse[]
  bankQuestions: QuestionResponse[]
}

export function LessonEditor({
  lesson,
  course,
  orgSlug,
  initialBlocks,
  bankQuestions,
}: LessonEditorProps) {
  const courseSlug = course.slug
  const lessonId = lesson.id
  const isPublished = course.status === "PUBLISHED"

  const [blocks, setBlocks] = useState<BlockResponse[]>(initialBlocks)
  const [isCreating, setIsCreating] = useState(false)
  const [pendingTitle, setPendingTitle] = useState("")
  const [pendingContent, setPendingContent] = useState("")
  const [newBlockTitle, setNewBlockTitle] = useState("")
  const [renamingBlockId, setRenamingBlockId] = useState<number | null>(null)
  const [renamingPending, setRenamingPending] = useState(false)
  const [renameTitle, setRenameTitle] = useState("")
  const [selectedBlockId, setSelectedBlockId] = useState<SelectedId>(
    isPublished ? (blocks.length > 0 ? blocks[0].id : null) : null
  )
  const [activeId, setActiveId] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const [dirty, setDirty] = useState(false)
  const [confirmDiscard, setConfirmDiscard] = useState(false)
  const pendingAction = useRef<(() => void) | null>(null)
  const [deletingBlock, setDeletingBlock] = useState<BlockResponse | null>(null)

  const isPendingSelected = selectedBlockId === "pending"

  const selectedBlock = isPendingSelected
    ? null
    : (blocks.find((b) => b.id === selectedBlockId) ?? null)

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 8 } }),
    useSensor(KeyboardSensor)
  )

  useEffect(() => {
    if (!dirty) return
    const handler = (e: BeforeUnloadEvent) => {
      e.preventDefault()
    }
    window.addEventListener("beforeunload", handler)
    return () => window.removeEventListener("beforeunload", handler)
  }, [dirty])

  function withDiscardCheck(action: () => void) {
    if (dirty) {
      pendingAction.current = action
      setConfirmDiscard(true)
    } else {
      action()
    }
  }

  function handleConfirmDiscard() {
    setConfirmDiscard(false)
    pendingAction.current?.()
    pendingAction.current = null
  }

  function startCreateBlock(title: string) {
    withDiscardCheck(() => {
      setIsCreating(true)
      setPendingTitle(title)
      setPendingContent("")
      setSelectedBlockId("pending")
    })
  }

  function selectRealBlock(blockId: number) {
    withDiscardCheck(() => {
      setIsCreating(false)
      setSelectedBlockId(blockId)
    })
  }

  function handleStartRenamePending() {
    setRenamingPending(true)
    setRenameTitle(pendingTitle)
  }

  function handleCommitRenamePending() {
    setRenamingPending(false)
    const title = renameTitle.trim()
    if (title) setPendingTitle(title)
  }

  function handleCancelCreate() {
    setIsCreating(false)
    setRenamingPending(false)
    setPendingTitle("")
    setSelectedBlockId(blocks.length > 0 ? blocks[0].id : null)
  }

  function handleStartRenameBlock(block: BlockResponse) {
    setRenamingBlockId(block.id)
    setRenameTitle(block.title ?? "")
  }

  async function handleCommitRenameBlock() {
    if (renamingBlockId === null) return
    const id = renamingBlockId
    const title = renameTitle.trim()
    setRenamingBlockId(null)
    setRenameTitle("")
    if (!title) return

    const original = blocks.find((b) => b.id === id)
    if (!original || original.title === title) return

    setBlocks((prev) => prev.map((b) => (b.id === id ? { ...b, title } : b)))
    const result = await updateBlockAction(
      id,
      { title },
      orgSlug,
      courseSlug,
      lessonId
    )
    if (result.error) {
      toast.error(result.error)
      setBlocks((prev) => prev.map((b) => (b.id === id ? original : b)))
    }
  }

  async function handleSave(content: string, questionId: number | null) {
    if (isPendingSelected) {
      setSaving(true)
      const result = await createBlockAction(
        lessonId,
        pendingTitle,
        content,
        questionId!,
        orgSlug,
        courseSlug
      )
      if (result.error) {
        toast.error(result.error)
        setSaving(false)
        return
      }
      if (result.block) {
        setBlocks((prev) => [...prev, result.block!])
        setSelectedBlockId(result.block!.id)
        setIsCreating(false)
        setPendingTitle("")
        setPendingContent("")
        setSaving(false)
        toast.success("تم إنشاء الفقرة بنجاح")
      }
    } else if (selectedBlockId && !isPendingSelected) {
      setSaving(true)
      const result = await updateBlockAction(
        selectedBlockId,
        {
          content,
          questionId: questionId ?? undefined,
        },
        orgSlug,
        courseSlug,
        lessonId
      )
      if (result.error) {
        toast.error(result.error)
        setSaving(false)
        return
      }
      if (result.block) {
        setBlocks((prev) =>
          prev.map((b) => (b.id === selectedBlockId ? result.block! : b))
        )
      }
      setSaving(false)
      toast.success("تم الحفظ بنجاح")
    }
  }

  async function handleDeleteBlock(block: BlockResponse) {
    setDeletingBlock(null)

    const result = await deleteBlockAction(
      block.id,
      orgSlug,
      courseSlug,
      lessonId
    )

    if (result.error) {
      toast.error(result.error)
      return
    }

    setBlocks((prev) => {
      const next = prev.filter((b) => b.id !== block.id)
      if (selectedBlockId === block.id) {
        const idx = prev.findIndex((b) => b.id === block.id)
        const newIdx = idx > 0 ? idx - 1 : next.length > 0 ? 0 : null
        setSelectedBlockId(newIdx !== null ? (next[newIdx]?.id ?? null) : null)
      }
      return next
    })

    toast.success("تم حذف الفقرة بنجاح")
  }

  function handleDragStart(event: DragStartEvent) {
    setActiveId(event.active.id as string)
  }

  async function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event
    setActiveId(null)

    if (!over || active.id === over.id) return

    const activeIdStr = active.id as string
    const overIdStr = over.id as string

    if (!activeIdStr.startsWith("block:") || !overIdStr.startsWith("block:"))
      return

    const activeNum = parseInt(activeIdStr.split(":")[1])
    const overNum = parseInt(overIdStr.split(":")[1])

    const oldIndex = blocks.findIndex((b) => b.id === activeNum)
    const newIndex = blocks.findIndex((b) => b.id === overNum)

    if (oldIndex === newIndex) return

    const previousBlocks = blocks
    const newBlocks = arrayMove(blocks, oldIndex, newIndex)
    setBlocks(newBlocks)

    const result = await reorderBlocksAction(
      lessonId,
      newBlocks.map((b) => b.id),
      orgSlug,
      courseSlug
    )

    if (result.error) {
      setBlocks(previousBlocks)
      toast.error(result.error)
    }
  }

  const activeBlock = activeId
    ? blocks.find((b) => b.id === parseInt(activeId.split(":")[1]))
    : null

  return (
    <>
      <div className="flex flex-col gap-4 lg:flex-row">
        <div className="order-first w-full lg:max-w-80 lg:min-w-60">
          <div className="mb-3">
            <h2 className="text-lg font-semibold">الفقرات</h2>
          </div>

          {blocks.length === 0 && isPublished ? (
            <Empty>
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <FileText />
                </EmptyMedia>
                <EmptyTitle>لا توجد فقرات</EmptyTitle>
                <EmptyDescription>
                  لم يتم إضافة فقرات لهذا الدرس بعد.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          ) : null}

          {blocks.length > 0 || isCreating || !isPublished ? (
            !isPublished ? (
              <DndContext
                sensors={sensors}
                onDragStart={handleDragStart}
                onDragEnd={handleDragEnd}
              >
                <SortableContext
                  items={blocks.map((b) => `block:${b.id}`)}
                  strategy={verticalListSortingStrategy}
                >
                  <div className="flex flex-col gap-2">
                    {blocks.map((block) => (
                      <BlockTile
                        key={block.id}
                        block={block}
                        isSelected={block.id === selectedBlockId}
                        onSelect={() => selectRealBlock(block.id)}
                        onDelete={() => setDeletingBlock(block)}
                        renaming={renamingBlockId === block.id}
                        renamingTitle={renameTitle}
                        onStartRename={() => handleStartRenameBlock(block)}
                        onRenameChange={setRenameTitle}
                        onCommitRename={handleCommitRenameBlock}
                      />
                    ))}
                  </div>
                </SortableContext>

                {isCreating && (
                  <div className="mt-2">
                    <PendingBlockTile
                      isSelected={isPendingSelected}
                      onSelect={() => setSelectedBlockId("pending")}
                      title={pendingTitle}
                      renaming={renamingPending}
                      renamingTitle={renameTitle}
                      onStartRename={handleStartRenamePending}
                      onRenameChange={setRenameTitle}
                      onCommitRename={handleCommitRenamePending}
                    />
                  </div>
                )}

                {!isCreating && (
                  <div className="mt-2 flex items-center gap-2 rounded-xl border border-dashed border-border bg-transparent p-3">
                    <Input
                      value={newBlockTitle}
                      onChange={(e) => setNewBlockTitle(e.target.value)}
                      placeholder="إضافة فقرة جديدة..."
                      className="h-6 rounded-none border-none bg-transparent px-0 text-sm shadow-none placeholder:text-muted-foreground focus-visible:ring-0"
                      onKeyDown={(e) => {
                        if (e.key === "Enter" && newBlockTitle.trim()) {
                          startCreateBlock(newBlockTitle.trim())
                          setNewBlockTitle("")
                        }
                      }}
                      onBlur={() => {
                        if (newBlockTitle.trim()) {
                          startCreateBlock(newBlockTitle.trim())
                          setNewBlockTitle("")
                        }
                      }}
                    />
                    <Plus className="size-4 shrink-0 text-muted-foreground" />
                  </div>
                )}

                <DragOverlay>
                  {activeBlock && (
                    <div className="flex items-center gap-2 rounded-xl border border-border bg-card p-3 shadow-lg">
                      <button className="touch-none text-muted-foreground">
                        <GripVertical className="size-4" />
                      </button>
                      <div className="min-w-0 flex-1">
                        <div className="truncate text-sm font-medium">
                          {activeBlock.title}
                        </div>
                      </div>
                      <Button variant="ghost" size="icon-xs">
                        <EllipsisVertical className="size-3" />
                      </Button>
                    </div>
                  )}
                </DragOverlay>
              </DndContext>
            ) : (
              <div className="flex flex-col gap-2">
                {blocks.map((block) => (
                  <BlockTile
                    key={block.id}
                    block={block}
                    isSelected={block.id === selectedBlockId}
                    onSelect={() => setSelectedBlockId(block.id)}
                    isPublished
                  />
                ))}
              </div>
            )
          ) : null}
        </div>

        <div className="flex min-w-0 flex-1 flex-col gap-6">
          {!selectedBlockId ? (
            <Empty>
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <FileText />
                </EmptyMedia>
                <EmptyTitle>اختر فقرة</EmptyTitle>
                <EmptyDescription>
                  اختر فقرة من القائمة لعرض المحتوى.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          ) : (
            <BlockEditorPanel
              key={selectedBlockId}
              block={selectedBlock}
              isPending={isPendingSelected}
              pendingContent={pendingContent}
              orgSlug={orgSlug}
              course={course}
              bankQuestions={bankQuestions}
              saving={saving}
              isPublished={isPublished}
              onSave={handleSave}
              onCancelCreate={handleCancelCreate}
              onDirtyChange={setDirty}
            />
          )}
        </div>
      </div>

      <AlertDialog
        open={!!confirmDiscard}
        onOpenChange={(open) => {
          if (!open) {
            setConfirmDiscard(false)
            pendingAction.current = null
          }
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>تغييرات غير محفوظة</AlertDialogTitle>
            <AlertDialogDescription>
              لديك تغييرات غير محفوظة. هل تريد تجاهلها؟
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleConfirmDiscard}>
              تجاهل
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog
        open={!!deletingBlock}
        onOpenChange={(open) => {
          if (!open) setDeletingBlock(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الفقرة</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذا الفقرة؟ لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => deletingBlock && handleDeleteBlock(deletingBlock)}
            >
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
