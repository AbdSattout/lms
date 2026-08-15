"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Skeleton } from "@/components/ui/skeleton"
import { Badge } from "@/components/ui/badge"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  Clock,
  XCircle,
  Pencil,
  Save,
  X,
  Link as LinkIcon,
  Loader2,
  Copy,
} from "lucide-react"
import { toast } from "sonner"
import { Role, OrganizationInviteResponse } from "@/lib/api/types"
import {
  getPendingInvites,
  cancelInvite,
  updateInviteCapacity,
} from "@/lib/actions/members"

export function PendingInvitesList({
  slug,
  role,
}: {
  slug: string
  role: Role
}) {
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])
  const [loading, setLoading] = useState(true)
  const [cancellingId, setCancellingId] = useState<number | null>(null)
  const [editingId, setEditingId] = useState<number | null>(null)
  const [editCapacity, setEditCapacity] = useState<number>(0)
  const [savingId, setSavingId] = useState<number | null>(null)

  useEffect(() => {
    let isMounted = true
    const fetchPendingInvites = async () => {
      setLoading(true)
      try {
        const rawData = await getPendingInvites(slug)

        const dataArr: OrganizationInviteResponse[] = Array.isArray(rawData)
          ? rawData
          : (rawData as { content?: OrganizationInviteResponse[] })?.content ||
            []

        const filteredList = dataArr.filter((inv) => inv.role === role)
        if (isMounted) setInvites(filteredList)
      } catch (e) {
        if (isMounted) toast.error("أخفق الخادم في تحميل القائمة الحالية")
      } finally {
        if (isMounted) setLoading(false)
      }
    }
    fetchPendingInvites()
    return () => {
      isMounted = false
    }
  }, [slug, role])

  const handleCancel = async (inviteId: number) => {
    setCancellingId(inviteId)
    try {
      await cancelInvite(slug, inviteId)
      setInvites(invites.filter((inv) => inv.id !== inviteId))
      toast.success("تم إسقاط هذا الطلب / الرابط بنجاح")
    } catch {
      toast.error("هناك خلل من الإلغاء, تحقق من توفرك")
    } finally {
      setCancellingId(null)
    }
  }

  const handleCopyLink = (invite: OrganizationInviteResponse) => {
    const domain = "https://lmscenter.vercel.app/"
    const copyTarget = `${domain}/invite/${invite.token || invite.id}`
    navigator.clipboard.writeText(copyTarget)
    toast.success("تم نسخ الرابط")
  }

  const handleStartEdit = (invite: OrganizationInviteResponse) => {
    if (invite.maxUses !== null) {
      setEditingId(invite.id)
      setEditCapacity(invite.maxUses)
    }
  }

  const handleSaveCapacity = async (inviteId: number) => {
    setSavingId(inviteId)
    try {
      const updated = await updateInviteCapacity(slug, inviteId, {
        maxUses: editCapacity,
      })
      setInvites(invites.map((inv) => (inv.id === inviteId ? updated : inv)))
      setEditingId(null)
      toast.success("تم تعديل عدد المقاعد بنجاح!")
    } catch {
      toast.error("فشل معالجة استعلام السعة الجديد")
    } finally {
      setSavingId(null)
    }
  }

  if (loading) {
    return (
      <div className="flex h-full flex-col space-y-3 p-4 pt-6">
        {[...Array(5)].map((_, i) => (
          <Skeleton key={i} className="h-[3.5rem] w-full rounded" />
        ))}
      </div>
    )
  }

  if (invites.length === 0) {
    return (
      <div className="flex h-full animate-in flex-col items-center justify-center space-y-4 bg-background/50 p-8 text-center zoom-in-95 fade-in">
        <div className="rounded-full bg-muted p-4">
          <Clock className="h-10 w-10 text-muted-foreground/30" />
        </div>
        <div>
          <p className="font-semibold text-foreground/80">
            لم يتم تسجيل روابط معلقة
          </p>
          <p className="mt-1 text-xs text-muted-foreground/80">
            لا يوجد دعوات نشطة.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-full flex-col bg-background pb-1">
      <div className="custom-scrollbar flex-1 overflow-auto overflow-x-auto border-t p-0">
        <Table className="w-full min-w-[500px] text-[13px] sm:min-w-fit">
          <TableHeader className="sticky top-0 z-10 border-b bg-muted/80 backdrop-blur">
            <TableRow className="h-9 hover:bg-transparent">
              <TableHead className="w-1/3 min-w-[120px] text-right font-semibold text-foreground">
                الاسم
              </TableHead>
              <TableHead className="text-center font-semibold text-foreground">
                الصنف
              </TableHead>
              <TableHead className="w-28 text-center font-semibold text-foreground">
                مقاعد
              </TableHead>
              <TableHead className="text-center text-transparent">-</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {invites.map((invite) => {
              const isSpecific = invite.maxUses === null

              return (
                <TableRow
                  key={invite.id}
                  className="group/row h-12 border-b-muted/50 hover:bg-muted/30"
                >
                  <TableCell className="align-middle">
                    <p
                      className="max-w-[150px] truncate leading-tight font-bold text-foreground"
                      title={invite.userName || "رابط استقطاب عام"}
                    >
                      {invite.userName || "استقطاب رابط عام"}
                    </p>
                    <p
                      className="mt-0.5 truncate text-[10px] font-medium text-muted-foreground opacity-80"
                      dir="rtl"
                    >
                      مدار بواسطة:
                      <span className="text-primary/70">
                        {invite.invitedByName || "مجهول"}
                      </span>
                    </p>
                  </TableCell>

                  <TableCell className="p-1 text-center align-middle whitespace-nowrap">
                    {!isSpecific ? (
                      <Badge
                        variant="outline"
                        className="w-[60px] justify-center border-indigo-200 bg-indigo-50/50 px-1 text-[10px] text-indigo-700"
                      >
                        <LinkIcon className="mr-1 inline h-3 w-3 opacity-70" />{" "}
                        عام
                      </Badge>
                    ) : (
                      <Badge
                        variant="outline"
                        className="w-[60px] justify-center border-neutral-200 bg-background px-1 text-[10px] text-foreground"
                      >
                        تخصيصي
                      </Badge>
                    )}
                  </TableCell>

                  <TableCell className="p-0 px-1 text-center align-middle font-mono whitespace-nowrap">
                    {!isSpecific ? (
                      editingId === invite.id ? (
                        <div className="flex flex-wrap items-center justify-center gap-1">
                          <Input
                            type="number"
                            min={invite.usedCount + 1}
                            max={5000}
                            value={editCapacity}
                            onChange={(e) =>
                              setEditCapacity(parseInt(e.target.value) || 1)
                            }
                            className="h-8 w-[3.5rem] border-primary/40 bg-background p-1 text-center text-xs shadow-sm"
                          />
                          <div className="ml-1 flex gap-0.5 rounded border bg-muted p-0.5">
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-6 w-6 text-green-600 hover:bg-green-100 hover:text-green-700"
                              onClick={() => handleSaveCapacity(invite.id)}
                            >
                              {savingId === invite.id ? (
                                <Loader2 className="h-3 w-3 animate-spin" />
                              ) : (
                                <Save className="h-3.5 w-3.5" />
                              )}
                            </Button>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-6 w-6 text-red-500 hover:bg-red-50 hover:text-red-700"
                              onClick={() => setEditingId(null)}
                            >
                              <X className="h-3.5 w-3.5" />
                            </Button>
                          </div>
                        </div>
                      ) : (
                        <div className="group/cap flex cursor-default items-center justify-center gap-1 transition-colors">
                          <span
                            className="rounded border border-dashed bg-background/50 px-2 py-0.5 text-xs font-semibold whitespace-pre text-foreground shadow-sm"
                            dir="ltr"
                          >
                            <span
                              className={
                                invite.usedCount >= invite.maxUses
                                  ? "text-destructive"
                                  : ""
                              }
                            >
                              {invite.usedCount}
                            </span>{" "}
                            / {invite.maxUses}
                          </span>
                          <Button
                            size="icon"
                            variant="ghost"
                            className="h-6 w-6 shrink-0 rounded bg-muted/40 opacity-0 transition-opacity group-hover/cap:opacity-100 hover:text-primary"
                            onClick={() => handleStartEdit(invite)}
                          >
                            <Pencil className="h-3 w-3" />
                          </Button>
                        </div>
                      )
                    ) : (
                      <span className="block px-2 text-[10px] text-muted-foreground/50">
                        بدون مقعد
                      </span>
                    )}
                  </TableCell>

                  <TableCell className="min-w-[70px] px-2 text-center align-middle whitespace-nowrap">
                    <div className="flex items-center justify-end gap-1">
                      {!isSpecific && (
                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-7 w-7 border border-transparent bg-indigo-50 text-indigo-500 shadow-sm hover:bg-indigo-100 hover:text-indigo-700 dark:border-indigo-900 dark:bg-indigo-500/10"
                          onClick={() => handleCopyLink(invite)}
                          title="انسخ الرابط"
                        >
                          <Copy className="h-3.5 w-3.5" />
                        </Button>
                      )}

                      <Button
                        size="icon"
                        variant="ghost"
                        className="hover:text-destructive-foreground h-7 w-7 bg-destructive/10 text-destructive shadow-sm hover:bg-destructive"
                        title="تعطيل الطلب والإزالة"
                        onClick={() => handleCancel(invite.id)}
                        disabled={cancellingId === invite.id}
                      >
                        {cancellingId === invite.id ? (
                          <Loader2 className="h-3 w-3 animate-spin opacity-50" />
                        ) : (
                          <XCircle className="h-3.5 w-3.5" />
                        )}
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
