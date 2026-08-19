"use client"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { useState } from "react"

const DURATIONS: { value: number; label: string }[] = [
  { value: 10, label: "10 دقائق" },
  { value: 30, label: "30 دقيقة" },
  { value: 60, label: "ساعة واحدة" },
  { value: 360, label: "6 ساعات" },
  { value: 1440, label: "24 ساعة" },
  { value: 10080, label: "7 أيام" },
]

export function MuteDialog({
  open,
  onOpenChange,
  userName,
  onConfirm,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  userName: string
  onConfirm: (durationMinutes: number, reason: string) => Promise<void>
}) {
  const [duration, setDuration] = useState(30)
  const [reason, setReason] = useState("")
  const [pending, setPending] = useState(false)

  function reset() {
    setDuration(30)
    setReason("")
    setPending(false)
  }

  async function handleConfirm() {
    setPending(true)
    try {
      await onConfirm(duration, reason.trim())
      onOpenChange(false)
      reset()
    } finally {
      setPending(false)
    }
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) reset()
        onOpenChange(next)
      }}
    >
      <DialogContent className="gap-4">
        <DialogHeader>
          <DialogTitle>كتم {userName}</DialogTitle>
          <DialogDescription>
            اختر مدة الكتم، ولن يتمكن {userName} من إرسال الرسائل خلال هذه
            الفترة.
          </DialogDescription>
        </DialogHeader>

        <div className="flex flex-col gap-2">
          <Label>مدة الكتم</Label>
          <Select
            value={String(duration)}
            onValueChange={(value) => setDuration(Number(value))}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="اختر المدة" />
            </SelectTrigger>
            <SelectContent>
              {DURATIONS.map((d) => (
                <SelectItem key={d.value} value={String(d.value)}>
                  {d.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="flex flex-col gap-2">
          <Label htmlFor="mute-reason">السبب (اختياري)</Label>
          <Textarea
            id="mute-reason"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="سبب الكتم..."
            className="min-h-20"
            maxLength={500}
          />
        </div>

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={pending}
          >
            إلغاء
          </Button>
          <Button
            variant="destructive"
            onClick={handleConfirm}
            disabled={pending}
          >
            كتم
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
