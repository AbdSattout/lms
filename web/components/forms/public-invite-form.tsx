"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Users, Link as LinkIcon, Loader2, Check, Copy } from "lucide-react"
import { toast } from "sonner"
import { Role } from "@/lib/api/types"
import { createPublicInvite } from "@/lib/actions/members"

export function PublicInviteForm({
  slug,
  role,
  onBack,
}: {
  slug: string
  role: Role
  onBack: () => void
}) {
  const [maxUses, setMaxUses] = useState<number>(10)
  const [inviting, setInviting] = useState(false)
  const [inviteLink, setInviteLink] = useState<string | null>(null)

  const handleCreatePublicInvite = async () => {
    setInviting(true)
    try {
      const result = await createPublicInvite(slug, {
        role: role,
        maxUses: maxUses,
      })

      const domain = "https://lmscenter.vercel.app/"
      setInviteLink(`${domain}/invite/${result.token ?? result.id}`)

      toast.success("تم تجهيز الرابط، أصبح متاحاً للاستخدام الآن")
    } catch {
      toast.error("فشل في إنشاء الرابط، تحقق من الاتصال")
    } finally {
      setInviting(false)
    }
  }

  return (
    <div className="flex h-full flex-col p-4">
      {!inviteLink ? (
        <div className="mx-auto flex h-full w-full max-w-sm flex-1 flex-col justify-center space-y-6 pt-10">
          <div className="space-y-4">
            <div className="mb-8 flex flex-col items-center justify-center gap-2">
              <Users className="h-12 w-12 text-muted-foreground opacity-30" />
              <p className="mt-4 text-center text-sm leading-relaxed text-muted-foreground">
                استخرج رابط دعوة قابلة لإعادة الاستخدام لعدد من الطلاب مع
                إمكانية تحديد الحد الأقصى للمقاعد المتاحة في الرابط.
              </p>
            </div>

            <Label
              htmlFor="maxUses"
              className="block text-right text-sm font-semibold"
            >
              السعة
            </Label>
            <Input
              id="maxUses"
              type="number"
              min={1}
              max={500}
              value={maxUses}
              className="h-12 bg-muted/40 text-center text-xl font-bold"
              onChange={(e) => setMaxUses(parseInt(e.target.value) || 1)}
            />
          </div>
          <div className="flex-1"></div>
          <Button
            onClick={handleCreatePublicInvite}
            disabled={inviting}
            className="h-12 w-full font-bold shadow-md transition-all hover:shadow-lg"
          >
            {inviting ? (
              <Loader2 className="ml-2 h-4 w-4 animate-spin" />
            ) : (
              <LinkIcon className="ml-2 h-4 w-4" />
            )}
            {inviting ? "جاري المعالجة..." : "إنشاء رابط دعوة جماعي"}
          </Button>
        </div>
      ) : (
        <div className="mx-auto flex w-full max-w-sm animate-in flex-col space-y-6 pt-10 text-sm text-foreground zoom-in-95">
          <div className="rounded-xl border bg-muted/20 p-8 text-center shadow-sm">
            <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/40">
              <Check className="h-6 w-6 text-green-600 dark:text-green-400" />
            </div>
            <p className="mb-8 font-semibold">الرابط جاهز للنسخ الآن!</p>

            <div className="flex gap-2">
              <Input
                value={inviteLink}
                readOnly
                dir="ltr"
                className="h-11 cursor-pointer truncate bg-background text-left font-mono text-[11px] font-semibold text-muted-foreground focus-visible:ring-1"
                onClick={(e) => (e.target as HTMLInputElement).select()}
              />
              <Button
                onClick={() => {
                  navigator.clipboard.writeText(inviteLink)
                  toast.success("تم حفظ الرابط في الحافظة!")
                }}
                size="icon"
                className="h-11 w-12 shrink-0 bg-primary/10 text-primary hover:bg-primary/20"
              >
                <Copy className="h-5 w-5" />
              </Button>
            </div>
          </div>

          <Button
            onClick={onBack}
            variant="outline"
            className="h-11 w-full gap-2"
          >
            إغلاق
          </Button>
        </div>
      )}
    </div>
  )
}
