"use client"

import type { MediaItemShape } from "@/components/cards/media-card"
import { MediaGrid } from "@/components/media-grid"
import { MediaGridSkeleton } from "@/components/skeletons/media-skeleton"
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
import { Input } from "@/components/ui/input"
import {
  Pagination,
  PaginationContent,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination"
import type {
  CourseMediaResponse,
  CourseResponse,
  PostMediaResponse,
} from "@/lib/api/types"
import { Upload } from "lucide-react"
import { useCallback, useEffect, useRef, useState } from "react"
import { toast } from "sonner"

const PAGE_SIZE = 24

export interface MediaLibraryProps {
  orgSlug: string
  organizationId: number
  course?: CourseResponse
  title: string
  onSelect?: (item: MediaItemShape) => void
  dialog?: boolean
  open?: boolean
  onOpenChange?: (open: boolean) => void
}

type MediaItem = PostMediaResponse | CourseMediaResponse

export function MediaLibrary({
  orgSlug,
  organizationId,
  course,
  title,
  onSelect,
  dialog = false,
  open,
  onOpenChange,
}: MediaLibraryProps) {
  const [items, setItems] = useState<MediaItem[]>([])
  const [page, setPage] = useState(0)
  const [totalPages, setTotalPages] = useState(0)
  const [loading, setLoading] = useState(true)
  const [editingItem, setEditingItem] = useState<MediaItem | null>(null)
  const [editName, setEditName] = useState("")
  const [deletingItem, setDeletingItem] = useState<MediaItem | null>(null)
  const [uploading, setUploading] = useState(false)
  const [saving, setSaving] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const replaceInputRef = useRef<HTMLInputElement>(null)
  const [replacingItem, setReplacingItem] = useState<MediaItem | null>(null)

  const isCourse = !!course

  const fetchItems = useCallback(async () => {
    setLoading(true)

    try {
      const { fetchCourseMediaAction, fetchPostMediaAction } =
        await import("@/lib/actions/media")

      const result = isCourse
        ? await fetchCourseMediaAction(organizationId, course.id, orgSlug, course.slug, page, PAGE_SIZE)
        : await fetchPostMediaAction(organizationId, orgSlug, page, PAGE_SIZE)

      setItems(result.content ?? [])
      setTotalPages(result.totalPages ?? 0)
    } catch {
      toast.error("حدث خطأ أثناء تحميل الوسائط")
    } finally {
      setLoading(false)
    }
  }, [orgSlug, organizationId, course, isCourse, page])

  useEffect(() => {
    if (dialog) {
      if (open) fetchItems()
    } else {
      fetchItems()
    }
  }, [fetchItems, dialog, open])

  async function handleUpload(file: File) {
    setUploading(true)

    try {
      const { uploadCourseMediaAction, uploadPostMediaAction } =
        await import("@/lib/actions/media")

      const result = isCourse
        ? await uploadCourseMediaAction(organizationId, course.id, orgSlug, course.slug, file)
        : await uploadPostMediaAction(organizationId, orgSlug, file)

      if (result.error) {
        toast.error(result.error)
      } else {
        toast.success("تم رفع الملف بنجاح")
        fetchItems()
      }
    } catch {
      toast.error("حدث خطأ أثناء رفع الملف")
    } finally {
      setUploading(false)
    }
  }

  async function handleDelete() {
    const item = deletingItem
    if (!item) return
    setDeletingItem(null)

    try {
      const { deleteCourseMediaAction, deletePostMediaAction } =
        await import("@/lib/actions/media")

      const result = isCourse
        ? await deleteCourseMediaAction(organizationId, course.id, orgSlug, course.slug, item.id)
        : await deletePostMediaAction(organizationId, orgSlug, item.id)

      if (result.error) {
        toast.error(result.error)
      } else {
        toast.success("تم حذف الملف بنجاح")
        setItems((prev) => prev.filter((x) => x.id !== item.id))
      }
    } catch {
      toast.error("حدث خطأ أثناء حذف الملف")
    }
  }

  async function handleSaveEdit() {
    if (!editingItem || !editName.trim()) return
    setSaving(true)

    try {
      const { updateCourseMediaAction, updatePostMediaAction } =
        await import("@/lib/actions/media")

      const result = isCourse
        ? await updateCourseMediaAction(organizationId, course.id, orgSlug, course.slug, editingItem.id, {
            name: editName.trim(),
          })
        : await updatePostMediaAction(organizationId, orgSlug, editingItem.id, {
            name: editName.trim(),
          })

      if (result.error) {
        toast.error(result.error)
      } else if (result.media) {
        setItems((prev) =>
          prev.map((x) => (x.id === editingItem.id ? result.media! : x))
        )
        toast.success("تم تحديث الاسم بنجاح")
      }
    } catch {
      toast.error("حدث خطأ أثناء تحديث الاسم")
    } finally {
      setSaving(false)
      setEditingItem(null)
    }
  }

  function handleReplaceFile(item: MediaItem) {
    setReplacingItem(item)
    replaceInputRef.current?.click()
  }

  async function onReplaceFileSelected(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file || !replacingItem) return

    setSaving(true)

    try {
      const { updateCourseMediaAction, updatePostMediaAction } =
        await import("@/lib/actions/media")

      const result = isCourse
        ? await updateCourseMediaAction(
            organizationId,
            course.id,
            orgSlug,
            course.slug,
            replacingItem.id,
            { file }
          )
        : await updatePostMediaAction(organizationId, orgSlug, replacingItem.id, { file })

      if (result.error) {
        toast.error(result.error)
      } else if (result.media) {
        setItems((prev) =>
          prev.map((x) => (x.id === replacingItem.id ? result.media! : x))
        )
        toast.success("تم استبدال الملف بنجاح")
      }
    } catch {
      toast.error("حدث خطأ أثناء استبدال الملف")
    } finally {
      setSaving(false)
      setReplacingItem(null)
      if (replaceInputRef.current) replaceInputRef.current.value = ""
    }
  }

  const paginationPages = Array.from({ length: totalPages }, (_, i) => i)

  const content = (
    <>
      <div className={dialog ? "" : "flex items-center justify-between"}>
        {!dialog && <h2 className="text-lg font-semibold">{title}</h2>}

        <div className="flex items-center gap-2">
          <input
            ref={fileInputRef}
            type="file"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0]
              if (file) handleUpload(file)
              if (fileInputRef.current) fileInputRef.current.value = ""
            }}
            accept="image/*,video/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv"
          />
          <input
            ref={replaceInputRef}
            type="file"
            className="hidden"
            onChange={onReplaceFileSelected}
            accept="image/*,video/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv"
          />
          <Button
            onClick={() => fileInputRef.current?.click()}
            disabled={uploading}
            size={dialog ? "sm" : "default"}
          >
            <Upload />
            {uploading ? "جاري الرفع..." : dialog ? "رفع" : "رفع ملف"}
          </Button>
        </div>
      </div>

      <div className={dialog ? "min-h-0 flex-1 overflow-y-auto" : ""}>
        {loading ? (
          <MediaGridSkeleton />
        ) : (
          <MediaGrid
            items={items}
            onSelect={
              dialog
                ? (item) => {
                    onSelect?.(item)
                    onOpenChange?.(false)
                  }
                : onSelect
            }
            onDelete={(item) => setDeletingItem(item)}
            onEditName={
              dialog
                ? undefined
                : (item) => {
                    setEditingItem(item)
                    setEditName(item.name)
                  }
            }
            onReplaceFile={dialog ? undefined : handleReplaceFile}
          />
        )}
      </div>

      {totalPages > 1 && (
        <Pagination>
          <PaginationContent>
            <PaginationItem>
              <PaginationPrevious
                text={dialog ? undefined : "السابق"}
                onClick={(e) => {
                  e.preventDefault()
                  if (page > 0) setPage(page - 1)
                }}
                className={
                  page === 0
                    ? "pointer-events-none opacity-50"
                    : "cursor-pointer"
                }
              />
            </PaginationItem>

            {paginationPages.map((p) => (
              <PaginationItem key={p}>
                <PaginationLink
                  onClick={(e) => {
                    e.preventDefault()
                    setPage(p)
                  }}
                  isActive={p === page}
                  className="cursor-pointer"
                >
                  {p + 1}
                </PaginationLink>
              </PaginationItem>
            ))}

            <PaginationItem>
              <PaginationNext
                text={dialog ? undefined : "التالي"}
                onClick={(e) => {
                  e.preventDefault()
                  if (page < totalPages - 1) setPage(page + 1)
                }}
                className={
                  page >= totalPages - 1
                    ? "pointer-events-none opacity-50"
                    : "cursor-pointer"
                }
              />
            </PaginationItem>
          </PaginationContent>
        </Pagination>
      )}

      {!dialog && (
        <Dialog
          open={!!editingItem}
          onOpenChange={(open) => {
            if (!open) setEditingItem(null)
          }}
        >
          <DialogContent>
            <DialogHeader>
              <DialogTitle>تعديل الاسم</DialogTitle>
            </DialogHeader>
            <div className="flex flex-col gap-4">
              <Input
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                placeholder="الاسم الجديد"
                onKeyDown={(e) => {
                  if (e.key === "Enter") handleSaveEdit()
                }}
              />
              <div className="flex justify-end gap-2">
                <Button variant="outline" onClick={() => setEditingItem(null)}>
                  إلغاء
                </Button>
                <Button onClick={handleSaveEdit} disabled={saving}>
                  {saving ? "جاري الحفظ..." : "حفظ"}
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}

      <AlertDialog
        open={!!deletingItem}
        onOpenChange={(open) => {
          if (!open) setDeletingItem(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الملف</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف &quot;{deletingItem?.name}&quot;؟ لا يمكن
              التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>حذف</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )

  if (dialog) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="flex max-h-[85dvh] max-w-5xl flex-col gap-4">
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
          </DialogHeader>
          {content}
        </DialogContent>
      </Dialog>
    )
  }

  return <div className="flex flex-col gap-4">{content}</div>
}
