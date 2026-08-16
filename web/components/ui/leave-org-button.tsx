"use client"

import { useState, useTransition } from "react"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { leaveOrganizationAction } from "@/lib/actions/organization"
import { toast } from "sonner"
import { LogOut } from "lucide-react"
import { useRouter } from "next/dist/client/components/navigation"

interface LeaveOrgButtonProps {
  slug: string
}

export function LeaveOrgButton({ slug }: LeaveOrgButtonProps) {
  const [open, setOpen] = useState(false)
  const [isPending, startTransition] = useTransition()
  const router = useRouter()
  function handleLeave() {
    startTransition(async () => {
      try {
        const result = await leaveOrganizationAction(slug)

        if (result?.error) {
          toast.error(result.error)
          return
        }

        if (result?.success) {
          setOpen(false)
          toast.success("تمت المغادرة بنجاح")
          router.push("/")
        }
      } catch (error) {
        console.log("Leave organization failed:", error)
        toast.error("فشل مغادرة المنظمة. حاول مرة أخرى.")
      }
    })
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger
        render={
          <Button
            variant="outline"
            className="gap-2 text-destructive hover:bg-destructive/10 hover:text-destructive"
          >
            <LogOut className="h-4 w-4" />
            مغادرة المنظمة
          </Button>
        }
      />
      <DialogContent dir="rtl">
        <DialogHeader>
          <DialogTitle>مغادرة المنظمة</DialogTitle>
          <DialogDescription className="pt-2">
            هل أنت متأكد من رغبتك في مغادرة هذه المنظمة؟ ستفقد الوصول إلى جميع
            محتوياتها بما في ذلك الكورسات والمنشورات. يمكنك الانضمام مجدداً في
            أي وقت إذا كانت المنظمة عامة أو من خلال دعوة جديدة.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter className="gap-2">
          <Button
            variant="outline"
            onClick={() => setOpen(false)}
            disabled={isPending}
          >
            إلغاء
          </Button>
          <Button
            variant="destructive"
            onClick={handleLeave}
            disabled={isPending}
          >
            {isPending ? "جاري المغادرة..." : "تأكيد المغادرة"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
