"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { toast } from "sonner"

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { deleteOrganizationAction } from "@/lib/actions/organization"
import { buttonVariants } from "./ui/button"

export function DeleteOrgButton({ slug }: { slug: string }) {
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleDelete = async () => {
    setLoading(true)

    try {
      const result = await deleteOrganizationAction(slug)

      if (!result.success) {
        toast.error(result.error)
        return
      }

      toast.success("تم حذف المنظمة بنجاح")
      router.replace("/")
      router.refresh()
    } catch (error) {
      console.error("Delete organization failed:", error)
      toast.error("حدث خطأ أثناء حذف المنظمة")
    } finally {
      setLoading(false)
    }
  }

  return (
    <AlertDialog>
      <AlertDialogTrigger
        className={buttonVariants({ variant: "destructive" })}
        disabled={loading}
      >
        حذف المنظمة
      </AlertDialogTrigger>

      <AlertDialogContent dir="rtl">
        <AlertDialogHeader>
          <AlertDialogTitle>هل أنت متأكد؟</AlertDialogTitle>

          <AlertDialogDescription>
            هذا الإجراء سيؤدي إلى حذف المنظمة نهائياً. لا يمكن التراجع عن هذا
            الإجراء.
          </AlertDialogDescription>
        </AlertDialogHeader>

        <AlertDialogFooter>
          <AlertDialogCancel disabled={loading}>إلغاء</AlertDialogCancel>

          <AlertDialogAction
            onClick={handleDelete}
            variant="destructive"
            disabled={loading}
          >
            {loading ? "جاري الحذف..." : "حذف"}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
