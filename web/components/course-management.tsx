"use client"

import { FinalQuizSection } from "@/components/final-quiz-section"
import { CourseFormDialog } from "@/components/forms/course-form-dialog"
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
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
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
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { Input } from "@/components/ui/input"
import { Separator } from "@/components/ui/separator"
import {
  createChapterAction,
  createLessonAction,
  deleteChapterAction,
  deleteLessonAction,
  reorderChaptersAction,
  reorderLessonsAction,
  updateChapterAction,
  updateLessonAction,
} from "@/lib/actions/course"
import type {
  ChapterResponse,
  CourseResponse,
  LessonResponse,
  QuestionResponse,
  QuizResponse,
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
  BookOpen,
  ClipboardList,
  EllipsisVertical,
  FileQuestion,
  FileText,
  GraduationCap,
  GripVertical,
  Image,
  Pen,
  Plus,
  Trash2,
} from "lucide-react"
import { useRouter } from "next/navigation"
import { useRef, useState } from "react"
import { toast } from "sonner"

interface CourseManagementProps {
  course: CourseResponse
  orgSlug: string
  initialChapters: ChapterResponse[]
  finalQuiz: QuizResponse | null
  bankQuestions: QuestionResponse[]
}

function SortableChapter({
  chapter,
  isSelected,
  isEditable,
  renaming,
  renamingTitle,
  onSelect,
  onStartRename,
  onRenameChange,
  onCommitRename,
  onDelete,
}: {
  chapter: ChapterResponse
  isSelected: boolean
  isEditable: boolean
  renaming: boolean
  renamingTitle: string
  onSelect: () => void
  onStartRename: () => void
  onRenameChange: (value: string) => void
  onCommitRename: () => void
  onDelete: () => void
}) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: `chapter:${chapter.id}`, disabled: !isEditable })

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
        if (isEditable && !renaming) onStartRename()
      }}
      className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
        isDragging ? "z-50 opacity-50" : ""
      } ${
        isSelected ? "border-primary bg-primary/5" : "border-border bg-card"
      }`}
    >
      {isEditable && (
        <button
          className="touch-none text-muted-foreground hover:text-foreground"
          onClick={(e) => e.stopPropagation()}
          {...attributes}
          {...listeners}
        >
          <GripVertical className="size-4" />
        </button>
      )}

      <div className="flex-1 truncate overflow-hidden rounded-3xl text-sm font-medium">
        {renaming ? (
          <Input
            value={renamingTitle}
            onChange={(e) => onRenameChange(e.target.value)}
            onBlur={onCommitRename}
            onKeyDown={(e) => {
              if (e.key === "Enter") onCommitRename()
              if (e.key === "Escape") onCommitRename()
            }}
            className="h-6 px-2 text-sm"
            autoFocus
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          chapter.title
        )}
      </div>

      {isEditable && (
        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            render={<Button variant="ghost" size="icon-xs" />}
          >
            <EllipsisVertical />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            <DropdownMenuItem
              onClick={(e) => {
                e.stopPropagation()
                onStartRename()
              }}
            >
              <Pen />
              تعديل
            </DropdownMenuItem>
            <DropdownMenuSeparator />
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
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </div>
  )
}

function SortableLesson({
  lesson,
  isEditable,
  renaming,
  renamingTitle,
  onSelect,
  onStartRename,
  onRenameChange,
  onCommitRename,
  onDelete,
}: {
  lesson: LessonResponse
  isEditable: boolean
  renaming: boolean
  renamingTitle: string
  onSelect: () => void
  onStartRename: () => void
  onRenameChange: (value: string) => void
  onCommitRename: () => void
  onDelete: () => void
}) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: `lesson:${lesson.id}`, disabled: !isEditable })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  const lastClickRef = useRef(0)
  const clickTimeoutRef = useRef<ReturnType<typeof setTimeout> | undefined>(
    undefined
  )

  function handleClick() {
    if (renaming) return
    const now = Date.now()
    if (now - lastClickRef.current < 350) {
      lastClickRef.current = 0
      if (clickTimeoutRef.current) clearTimeout(clickTimeoutRef.current)
      if (isEditable) onStartRename()
      return
    }
    lastClickRef.current = now
    clickTimeoutRef.current = setTimeout(onSelect, 250)
  }

  function handleDoubleClick() {
    if (clickTimeoutRef.current) clearTimeout(clickTimeoutRef.current)
    lastClickRef.current = 0
    if (isEditable && !renaming) onStartRename()
  }

  return (
    <div
      ref={setNodeRef}
      style={style}
      onClick={renaming ? undefined : handleClick}
      onDoubleClick={renaming ? undefined : handleDoubleClick}
      className={`flex cursor-pointer items-center gap-2 rounded-xl border border-border bg-card p-3 transition-colors ${
        isDragging ? "z-50 opacity-50" : ""
      }`}
    >
      {isEditable && (
        <button
          className="touch-none text-muted-foreground hover:text-foreground"
          onClick={(e) => e.stopPropagation()}
          {...attributes}
          {...listeners}
        >
          <GripVertical className="size-4" />
        </button>
      )}

      <div className="flex-1 truncate overflow-hidden rounded-3xl text-sm font-medium">
        {renaming ? (
          <Input
            value={renamingTitle}
            onChange={(e) => onRenameChange(e.target.value)}
            onBlur={onCommitRename}
            onKeyDown={(e) => {
              if (e.key === "Enter") onCommitRename()
              if (e.key === "Escape") onCommitRename()
            }}
            className="h-6 px-2 text-sm"
            autoFocus
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          lesson.title
        )}
      </div>

      {isEditable && (
        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            render={<Button variant="ghost" size="icon-xs" />}
          >
            <EllipsisVertical />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            <DropdownMenuItem
              onClick={(e) => {
                e.stopPropagation()
                onStartRename()
              }}
            >
              <Pen />
              تعديل
            </DropdownMenuItem>
            <DropdownMenuSeparator />
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
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </div>
  )
}

export function CourseManagement({
  course,
  orgSlug,
  initialChapters,
  finalQuiz,
  bankQuestions,
}: CourseManagementProps) {
  const router = useRouter()
  const isEditable = course.status === "DRAFT"

  const [chapters, setChapters] = useState<ChapterResponse[]>(initialChapters)
  const [selectedChapterId, setSelectedChapterId] = useState<number | null>(
    null
  )
  const [activeId, setActiveId] = useState<string | null>(null)
  const [editOpen, setEditOpen] = useState(false)

  const [renamingChapterId, setRenamingChapterId] = useState<number | null>(
    null
  )
  const [renamingLessonId, setRenamingLessonId] = useState<number | null>(null)
  const [renameTitle, setRenameTitle] = useState("")

  const [newChapterTitle, setNewChapterTitle] = useState("")
  const [newLessonTitle, setNewLessonTitle] = useState("")

  const [deletingChapter, setDeletingChapter] =
    useState<ChapterResponse | null>(null)
  const [deletingLesson, setDeletingLesson] = useState<LessonResponse | null>(
    null
  )

  const selectedChapter =
    chapters.find((c) => c.id === selectedChapterId) ?? null
  const lessons = selectedChapter?.lessons ?? []

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 8 } }),
    useSensor(KeyboardSensor)
  )

  async function handleCreateChapter(title: string) {
    if (!title.trim()) return
    setNewChapterTitle("")
    const result = await createChapterAction(course.id, title.trim(), orgSlug)
    if (result.error) {
      toast.error(result.error)
      return
    }
    if (result.chapter) {
      const newChapter: ChapterResponse = { ...result.chapter, lessons: [] }
      setChapters((prev) => [...prev, newChapter])
      setSelectedChapterId(newChapter.id)
      toast.success("تم إنشاء الفصل بنجاح")
    }
  }

  function handleStartRenameChapter(chapter: ChapterResponse) {
    setRenamingChapterId(chapter.id)
    setRenameTitle(chapter.title)
  }

  async function handleCommitRenameChapter() {
    if (renamingChapterId === null) return
    const id = renamingChapterId
    const title = renameTitle.trim()
    setRenamingChapterId(null)
    setRenameTitle("")
    if (!title) return

    const original = chapters.find((c) => c.id === id)
    if (!original || original.title === title) return

    setChapters((prev) =>
      prev.map((ch) => (ch.id === id ? { ...ch, title } : ch))
    )
    const result = await updateChapterAction(id, title, orgSlug)
    if (result.error) toast.error(result.error)
  }

  async function handleDeleteChapter(chapter: ChapterResponse) {
    setChapters((prev) => prev.filter((ch) => ch.id !== chapter.id))
    if (selectedChapterId === chapter.id) {
      const next = chapters.find((c) => c.id !== chapter.id)
      setSelectedChapterId(next?.id ?? null)
    }
    setDeletingChapter(null)
    const result = await deleteChapterAction(chapter.id, orgSlug)
    if (result.error) toast.error(result.error)
    else toast.success("تم حذف الفصل بنجاح")
  }

  async function handleCreateLesson(title: string) {
    if (!title.trim() || !selectedChapterId) return
    setNewLessonTitle("")
    const result = await createLessonAction(
      selectedChapterId,
      title.trim(),
      orgSlug
    )
    if (result.error) {
      toast.error(result.error)
      return
    }
    if (result.lesson) {
      setChapters((prev) =>
        prev.map((ch) =>
          ch.id === selectedChapterId
            ? { ...ch, lessons: [...ch.lessons, result.lesson!] }
            : ch
        )
      )
      toast.success("تم إنشاء الدرس بنجاح")
    }
  }

  function handleStartRenameLesson(lesson: LessonResponse) {
    setRenamingLessonId(lesson.id)
    setRenameTitle(lesson.title)
  }

  async function handleCommitRenameLesson() {
    if (renamingLessonId === null) return
    const id = renamingLessonId
    const title = renameTitle.trim()
    setRenamingLessonId(null)
    setRenameTitle("")
    if (!title) return

    let original: LessonResponse | undefined
    for (const ch of chapters) {
      original = ch.lessons.find((l) => l.id === id)
      if (original) break
    }
    if (!original || original.title === title) return

    setChapters((prev) =>
      prev.map((ch) => ({
        ...ch,
        lessons: ch.lessons.map((l) => (l.id === id ? { ...l, title } : l)),
      }))
    )
    const result = await updateLessonAction(id, { title }, orgSlug)
    if (result.error) toast.error(result.error)
  }

  async function handleDeleteLesson(lesson: LessonResponse) {
    setChapters((prev) =>
      prev.map((ch) => ({
        ...ch,
        lessons: ch.lessons.filter((l) => l.id !== lesson.id),
      }))
    )
    setDeletingLesson(null)
    const result = await deleteLessonAction(lesson.id, orgSlug)
    if (result.error) toast.error(result.error)
    else toast.success("تم حذف الدرس بنجاح")
  }

  function handleDragStart(event: DragStartEvent) {
    setActiveId(event.active.id as string)
  }

  async function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event
    if (!over || active.id === over.id) {
      setActiveId(null)
      return
    }

    const activeIdStr = active.id as string
    const overIdStr = over.id as string
    const [activeType, activeIdNum] = activeIdStr.split(":")
    const numericId = parseInt(activeIdNum)

    if (activeType === "chapter") {
      const oldIndex = chapters.findIndex((c) => c.id === numericId)
      let newIndex: number
      if (overIdStr.startsWith("chapter:")) {
        newIndex = chapters.findIndex(
          (c) => c.id === parseInt(overIdStr.split(":")[1])
        )
      } else {
        newIndex = chapters.length - 1
      }
      if (oldIndex === newIndex) {
        setActiveId(null)
        return
      }

      const newChapters = arrayMove(chapters, oldIndex, newIndex)
      setChapters(newChapters)
      const result = await reorderChaptersAction(
        course.id,
        newChapters.map((c) => c.id),
        orgSlug
      )
      if (result.error) toast.error(result.error)
    } else if (activeType === "lesson") {
      const overType = overIdStr.split(":")[0]
      if (overType === "chapter") {
        const targetChapterId = parseInt(overIdStr.split(":")[1])
        if (targetChapterId === selectedChapterId) {
          setActiveId(null)
          return
        }

        const sourceChapter = chapters.find((c) => c.id === selectedChapterId)
        const lesson = sourceChapter?.lessons.find((l) => l.id === numericId)
        if (!lesson) {
          setActiveId(null)
          return
        }

        setChapters((prev) =>
          prev.map((ch) => {
            if (ch.id === selectedChapterId) {
              return {
                ...ch,
                lessons: ch.lessons.filter((l) => l.id !== numericId),
              }
            }
            if (ch.id === targetChapterId) {
              return { ...ch, lessons: [...ch.lessons, { ...lesson }] }
            }
            return ch
          })
        )

        const sourceLen = sourceChapter?.lessons.length ?? 0
        if (sourceLen <= 1) {
          setSelectedChapterId(targetChapterId)
        }

        const result = await updateLessonAction(
          numericId,
          { chapterId: targetChapterId },
          orgSlug
        )
        if (result.error) toast.error(result.error)
        else toast.success("تم نقل الدرس بنجاح")
      } else if (overType === "lesson" && selectedChapter) {
        const overLessonId = parseInt(overIdStr.split(":")[1])
        const oldIndex = lessons.findIndex((l) => l.id === numericId)
        const newIndex = lessons.findIndex((l) => l.id === overLessonId)
        if (oldIndex === newIndex) {
          setActiveId(null)
          return
        }

        const newLessons = arrayMove(lessons, oldIndex, newIndex)
        setChapters((prev) =>
          prev.map((ch) =>
            ch.id === selectedChapterId ? { ...ch, lessons: newLessons } : ch
          )
        )
        const result = await reorderLessonsAction(
          selectedChapterId!,
          newLessons.map((l) => l.id),
          orgSlug
        )
        if (result.error) toast.error(result.error)
      }
    }

    setActiveId(null)
  }

  const activeItem = activeId
    ? (() => {
        const [type, id] = activeId.split(":")
        if (type === "chapter") {
          const ch = chapters.find((c) => c.id === parseInt(id))
          return ch ? { title: ch.title, type: "chapter" as const } : null
        }
        if (type === "lesson") {
          for (const ch of chapters) {
            const l = ch.lessons.find((l) => l.id === parseInt(id))
            if (l) return { title: l.title, type: "lesson" as const }
          }
        }
        return null
      })()
    : null

  return (
    <>
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <Card
          className="cursor-pointer transition-colors hover:bg-accent/50"
          onClick={() => setEditOpen(true)}
        >
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BookOpen className="size-4" />
              تعديل معلومات الدورة
            </CardTitle>
            <CardDescription>تعديل العنوان والوصف والصورة</CardDescription>
          </CardHeader>
        </Card>

        <Card
          className="cursor-pointer transition-colors hover:bg-accent/50"
          onClick={() =>
            router.push(`/${orgSlug}/courses/${course.slug}/questions` as never)
          }
        >
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <FileQuestion className="size-4" />
              بنك الأسئلة
            </CardTitle>
            <CardDescription>إدارة أسئلة الدورة</CardDescription>
          </CardHeader>
        </Card>

        <Card
          className="cursor-pointer transition-colors hover:bg-accent/50"
          onClick={() =>
            router.push(`/${orgSlug}/courses/${course.slug}/quizzes` as never)
          }
        >
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <ClipboardList className="size-4" />
              الاختبارات
            </CardTitle>
            <CardDescription>إدارة اختبارات الدورة</CardDescription>
          </CardHeader>
        </Card>

        <Card
          className="cursor-pointer transition-colors hover:bg-accent/50"
          onClick={() =>
            router.push(`/${orgSlug}/courses/${course.slug}/media` as never)
          }
        >
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              {/* eslint-disable-next-line jsx-a11y/alt-text */}
              <Image className="size-4" aria-hidden="true" />
              الوسائط
            </CardTitle>
            <CardDescription>إدارة ملفات الدورة</CardDescription>
          </CardHeader>
        </Card>
      </div>

      <Separator />
      <DndContext
        sensors={sensors}
        onDragStart={handleDragStart}
        onDragEnd={handleDragEnd}
      >
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div className="flex flex-col gap-3">
            <h2 className="text-lg font-semibold">الفصول</h2>

            <div className="flex flex-col gap-2">
              {chapters.length === 0 && !isEditable ? (
                <Empty>
                  <EmptyHeader>
                    <EmptyMedia variant="icon">
                      <GraduationCap />
                    </EmptyMedia>
                    <EmptyTitle>لا توجد فصول</EmptyTitle>
                  </EmptyHeader>
                  <EmptyContent>لم يتم إضافة فصول لهذه الدورة بعد</EmptyContent>
                </Empty>
              ) : (
                <SortableContext
                  items={chapters.map((c) => `chapter:${c.id}`)}
                  strategy={verticalListSortingStrategy}
                >
                  {chapters.map((chapter) => (
                    <SortableChapter
                      key={chapter.id}
                      chapter={chapter}
                      isSelected={chapter.id === selectedChapterId}
                      isEditable={isEditable}
                      renaming={renamingChapterId === chapter.id}
                      renamingTitle={
                        renamingChapterId === chapter.id ? renameTitle : ""
                      }
                      onSelect={() => setSelectedChapterId(chapter.id)}
                      onStartRename={() => handleStartRenameChapter(chapter)}
                      onRenameChange={setRenameTitle}
                      onCommitRename={handleCommitRenameChapter}
                      onDelete={() => setDeletingChapter(chapter)}
                    />
                  ))}
                </SortableContext>
              )}

              {isEditable && (
                <div className="flex items-center gap-2 rounded-xl border border-dashed border-border bg-transparent p-3">
                  <Input
                    value={newChapterTitle}
                    onChange={(e) => setNewChapterTitle(e.target.value)}
                    placeholder="إضافة فصل جديد..."
                    className="h-6 rounded-none border-none bg-transparent px-0 text-sm shadow-none placeholder:text-muted-foreground focus-visible:ring-0"
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        handleCreateChapter(newChapterTitle)
                      }
                    }}
                    onBlur={() => {
                      if (newChapterTitle.trim()) {
                        handleCreateChapter(newChapterTitle)
                      }
                    }}
                  />
                  <Plus className="size-4 shrink-0 text-muted-foreground" />
                </div>
              )}
            </div>
          </div>

          <div className="flex flex-col gap-3">
            <h2 className="text-lg font-semibold">
              {selectedChapter ? `دروس ${selectedChapter.title}` : "الدروس"}
            </h2>

            {!selectedChapter ? (
              <Empty>
                <EmptyHeader>
                  <EmptyMedia variant="icon">
                    <GraduationCap />
                  </EmptyMedia>
                  <EmptyTitle>اختر فصلاً</EmptyTitle>
                </EmptyHeader>
                <EmptyContent>اختر فصلاً من القائمة لعرض دروسه</EmptyContent>
              </Empty>
            ) : lessons.length === 0 && !isEditable ? (
              <Empty>
                <EmptyHeader>
                  <EmptyMedia variant="icon">
                    <FileText />
                  </EmptyMedia>
                  <EmptyTitle>لا توجد دروس</EmptyTitle>
                </EmptyHeader>
                <EmptyContent>لا توجد دروس في هذا الفصل بعد</EmptyContent>
              </Empty>
            ) : (
              <div className="flex flex-col gap-2">
                {lessons.length > 0 && (
                  <SortableContext
                    items={lessons.map((l) => `lesson:${l.id}`)}
                    strategy={verticalListSortingStrategy}
                  >
                    {lessons.map((lesson) => (
                      <SortableLesson
                        key={lesson.id}
                        lesson={lesson}
                        isEditable={isEditable}
                        renaming={renamingLessonId === lesson.id}
                        renamingTitle={
                          renamingLessonId === lesson.id ? renameTitle : ""
                        }
                        onSelect={() =>
                          router.push(
                            `${course.slug}/lessons/${lesson.id}` as unknown as Parameters<
                              typeof router.push
                            >[0]
                          )
                        }
                        onStartRename={() => handleStartRenameLesson(lesson)}
                        onRenameChange={setRenameTitle}
                        onCommitRename={handleCommitRenameLesson}
                        onDelete={() => setDeletingLesson(lesson)}
                      />
                    ))}
                  </SortableContext>
                )}

                {isEditable && (
                  <div className="flex items-center gap-2 rounded-xl border border-dashed border-border bg-transparent p-3">
                    <Input
                      value={newLessonTitle}
                      onChange={(e) => setNewLessonTitle(e.target.value)}
                      placeholder="إضافة درس جديد..."
                      className="h-6 rounded-none border-none bg-transparent px-0 text-sm shadow-none placeholder:text-muted-foreground focus-visible:ring-0"
                      onKeyDown={(e) => {
                        if (e.key === "Enter") {
                          handleCreateLesson(newLessonTitle)
                        }
                      }}
                      onBlur={() => {
                        if (newLessonTitle.trim()) {
                          handleCreateLesson(newLessonTitle)
                        }
                      }}
                    />
                    <Plus className="size-4 shrink-0 text-muted-foreground" />
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        <DragOverlay>
          {activeItem && (
            <div className="flex items-center gap-2 rounded-xl border border-border bg-card p-3 shadow-lg">
              <GripVertical className="size-4 text-muted-foreground" />
              <span className="truncate text-sm font-medium">
                {activeItem.title}
              </span>
              <Button variant="ghost" size="icon-xs" />
            </div>
          )}
        </DragOverlay>
      </DndContext>

      <FinalQuizSection
        course={course}
        orgSlug={orgSlug}
        initialQuiz={finalQuiz}
        initialBankQuestions={bankQuestions}
        isEditable={isEditable}
      />

      <CourseFormDialog
        key={course.id}
        open={editOpen}
        onOpenChange={setEditOpen}
        orgSlug={orgSlug}
        course={course}
      />

      <AlertDialog
        open={!!deletingChapter}
        onOpenChange={(open) => {
          if (!open) setDeletingChapter(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الفصل</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف فصل &quot;{deletingChapter?.title}&quot;؟ جميع
              الدروس المرتبطة به سيتم حذفها أيضاً. لا يمكن التراجع عن هذا
              الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={() =>
                deletingChapter && handleDeleteChapter(deletingChapter)
              }
            >
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog
        open={!!deletingLesson}
        onOpenChange={(open) => {
          if (!open) setDeletingLesson(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الدرس</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف درس &quot;{deletingLesson?.title}&quot;؟ لا
              يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={() =>
                deletingLesson && handleDeleteLesson(deletingLesson)
              }
            >
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
