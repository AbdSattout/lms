"use client"
import type { Route } from "next"
import { Button } from "@/components/ui/button"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import type { RoadmapResponse } from "@/lib/api/types"
import { Map, Plus, Loader2 } from "lucide-react"
import { useRouter } from "next/navigation"
import { useTransition, useState } from "react"
import { toast } from "sonner"
import { RoadmapCard } from "./cards/roadmap-card"
import {
  deleteRoadmap,
  moveRoadmapToDraft,
  publishRoadmap,
} from "@/lib/actions/roadmap"

interface RoadmapsContentProps {
  orgSlug: string
  roadmaps: RoadmapResponse[]
}

export function RoadmapsContent({ orgSlug, roadmaps }: RoadmapsContentProps) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [statusTargetId, setStatusTargetId] = useState<number | null>(null)

  const isChangingStatus = isPending && statusTargetId !== null
  const [deleteTargetId, setDeleteTargetId] = useState<number | null>(null)
  const isDeleting = isPending && deleteTargetId !== null

  const handleCreateRoadmap = () => {
    startTransition(() => router.push(`/${orgSlug}/roadmaps/new` as Route))
  }

  const handleEditRoadmap = (roadmapId: number) => {
    startTransition(() =>
      router.push(`/${orgSlug}/roadmaps/${roadmapId}` as Route)
    )
  }
  const handleStatusToggle = (roadmap: RoadmapResponse) => {
    setStatusTargetId(roadmap.id)

    startTransition(async () => {
      try {
        const result =
          roadmap.status === "PUBLISHED"
            ? await moveRoadmapToDraft(orgSlug, roadmap.id)
            : await publishRoadmap(orgSlug, roadmap.id)

        if (result?.error) {
          const errorMessage = result.error

          if (
            errorMessage.includes(
              "All roadmap courses must be published before publishing roadmap"
            )
          ) {
            toast.error(
              "لا يمكن نشر المسار لأن إحدى الدورات الموجودة فيه غير منشورة."
            )
          } else {
            toast.error(errorMessage)
          }

          return
        }

        toast.success(
          roadmap.status === "PUBLISHED"
            ? "تم تحويل المسار إلى مسودة"
            : "تم نشر المسار التعليمي بنجاح"
        )
      } catch (error) {
        console.error("Roadmap status update failed:", error)

        toast.error("حدث خطأ أثناء تحديث حالة المسار.")
      } finally {
        setStatusTargetId(null)
      }
    })
  }
  const handleDeleteConfirm = () => {
    if (!deleteTargetId) return
    startTransition(async () => {
      try {
        const result = await deleteRoadmap(orgSlug, deleteTargetId)
        if (result?.error) throw new Error(result.error)
        toast.success("تم حذف المسار التعليمي بنجاح")
      } catch {
        toast.error("حدث خطأ أثناء حذف المسار")
      } finally {
        setDeleteTargetId(null)
      }
    })
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">المسارات التعليمية</h1>

        {roadmaps.length > 0 && (
          <Button onClick={handleCreateRoadmap} disabled={isPending}>
            <Plus className="ml-1.5 h-4 w-4" />
            إضافة مسار تعليمي
          </Button>
        )}
      </div>

      {roadmaps.length === 0 ? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <Map />
            </EmptyMedia>
            <EmptyTitle>لا توجد مسارات تعليمية بعد</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>
            <Button onClick={handleCreateRoadmap} disabled={isPending}>
              <Plus className="ml-1.5 h-4 w-4" /> إضافة مسار تعليمي
            </Button>
          </EmptyContent>
        </Empty>
      ) : (
        <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4">
          {roadmaps.map((roadmap) => (
            <RoadmapCard
              key={roadmap.id}
              roadmap={roadmap}
              onClick={() => handleEditRoadmap(roadmap.id)}
              onDelete={() => setDeleteTargetId(roadmap.id)}
              onStatusToggle={() => handleStatusToggle(roadmap)}
              isStatusPending={
                isChangingStatus && statusTargetId === roadmap.id
              }
            />
          ))}
        </div>
      )}

      <Dialog
        open={deleteTargetId !== null}
        onOpenChange={(v) => !v && setDeleteTargetId(null)}
      >
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من رغبتك في حذف هذا المسار التعليمي بشكل نهائي؟ لا
              يمكن التراجع عن هذه الخطوة وسيتم فقده بالكامل.
            </DialogDescription>
          </DialogHeader>
          <div className="mt-4 flex justify-end gap-2">
            <Button
              variant="ghost"
              onClick={() => setDeleteTargetId(null)}
              disabled={isDeleting}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleDeleteConfirm}
              disabled={isDeleting}
            >
              {isDeleting && <Loader2 className="ml-2 h-4 w-4 animate-spin" />}{" "}
              حذف
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
