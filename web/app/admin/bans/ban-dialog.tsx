"use client"

import { useState, useTransition } from "react"
import { Loader2 } from "lucide-react"
import { toast } from "sonner"

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

import type { BanDuration, BanRequest } from "@/lib/api/types"
import {
  banOrganizationAction,
  banUserAction,
} from "@/lib/actions/admin-moderation"

const durations: Array<{
  value: BanDuration
  label: string
}> = [
  {
    value: "DAY",
    label: "يوم واحد",
  },
  {
    value: "WEEK",
    label: "أسبوع",
  },
  {
    value: "MONTH",
    label: "شهر",
  },
  {
    value: "YEAR",
    label: "سنة",
  },
  {
    value: "PERMANENT",
    label: "دائم",
  },
]

interface BanDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  target:
    | {
        type: "USER"
        id: number
        name: string
      }
    | {
        type: "ORGANIZATION"
        id: number
        name: string
      }
  onBanned?: () => void
}

export function BanDialog({
  open,
  onOpenChange,
  target,
  onBanned,
}: BanDialogProps) {
  const [duration, setDuration] = useState<BanDuration>("PERMANENT")
  const [reason, setReason] = useState("")
  const [isSubmitting, startSubmitting] = useTransition()

  function handleSubmit() {
    if (!reason.trim()) {
      toast.error("سبب الحظر مطلوب")
      return
    }

    const request: BanRequest = {
      reason: reason.trim(),
      duration,
    }

    startSubmitting(async () => {
      try {
        if (target.type === "USER") {
          await banUserAction(target.id, request)
        } else {
          await banOrganizationAction(target.id, request)
        }

        toast.success("تم تنفيذ الحظر بنجاح")

        setReason("")
        setDuration("PERMANENT")
        onOpenChange(false)
        onBanned?.()
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "فشل تنفيذ الحظر")
      }
    })
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        if (!isSubmitting) {
          onOpenChange(nextOpen)
        }
      }}
    >
      <DialogContent dir="rtl" className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>
            حظر {target.type === "USER" ? "المستخدم" : "المنظمة"}
          </DialogTitle>

          <DialogDescription>
            سيتم حظر <strong>{target.name}</strong> وفقاً للمدة المحددة أدناه.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-5 py-2">
          <div className="space-y-2">
            <label className="text-sm font-semibold">مدة الحظر</label>

            <Select
              value={duration}
              onValueChange={(value) => setDuration(value as BanDuration)}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>

              <SelectContent>
                {durations.map((item) => (
                  <SelectItem key={item.value} value={item.value}>
                    {item.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-semibold">سبب الحظر</label>

            <Textarea
              value={reason}
              onChange={(event) => setReason(event.target.value)}
              placeholder="اكتب سبب الحظر..."
              className="min-h-28 resize-y"
              maxLength={1000}
            />

            <p className="text-xs text-muted-foreground">
              {reason.length}/1000
            </p>
          </div>
        </div>

        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            disabled={isSubmitting}
            onClick={() => onOpenChange(false)}
          >
            إلغاء
          </Button>

          <Button
            type="button"
            variant="destructive"
            disabled={isSubmitting || !reason.trim()}
            onClick={handleSubmit}
          >
            {isSubmitting && <Loader2 className="ml-2 h-4 w-4 animate-spin" />}

            {isSubmitting ? "جاري الحظر..." : "تأكيد الحظر"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
