"use client"

import { useEffect, useState } from "react"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  Loader2,
  RefreshCw,
  XCircle,
  Users,
  User,
  Clock,
  X,
  Pencil,
  Save,
} from "lucide-react"
import { toast } from "sonner"

import { OrganizationInviteResponse } from "@/lib/api/types"
import {
  getPendingInvites,
  cancelInvite,
  updateInviteCapacity,
} from "@/lib/actions/members"

interface PendingInvitesDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  slug: string
}

export function PendingInvitesDialog({
  open,
  onOpenChange,
  slug,
}: PendingInvitesDialogProps) {
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])
  const [loading, setLoading] = useState(false)
  const [cancellingId, setCancellingId] = useState<number | null>(null)
  const [editingId, setEditingId] = useState<number | null>(null)
  const [editCapacity, setEditCapacity] = useState<number>(0)
  const [savingId, setSavingId] = useState<number | null>(null)

  const fetchInvites = async () => {
    if (!open) return

    setLoading(true)
    try {
      const data = await getPendingInvites(slug)
      setInvites(data ?? [])
    } catch (error) {
      console.error("Failed to fetch pending invites:", error)
      toast.error("فشل في تحميل الدعوات المعلقة")
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchInvites()
  }, [open, slug])

  const handleCancel = async (inviteId: number) => {
    setCancellingId(inviteId)
    try {
      await cancelInvite(slug, inviteId)
      setInvites(invites.filter((inv) => inv.id !== inviteId))
      toast.success("تم إلغاء الدعوة بنجاح")
    } catch (error) {
      console.error("Failed to cancel invite:", error)
      toast.error("فشل في إلغاء الدعوة")
    } finally {
      setCancellingId(null)
    }
  }

  const handleStartEdit = (invite: OrganizationInviteResponse) => {
    setEditingId(invite.id)
    setEditCapacity(invite.maxUses)
  }

  const handleSaveCapacity = async (inviteId: number) => {
    setSavingId(inviteId)
    try {
      const updated = await updateInviteCapacity(slug, inviteId, {
        maxUses: editCapacity,
      })
      setInvites(invites.map((inv) => (inv.id === inviteId ? updated : inv)))
      setEditingId(null)
      toast.success("تم تحديث السعة بنجاح")
    } catch (error) {
      console.error("Failed to update capacity:", error)
      toast.error("فشل في تحديث السعة")
    } finally {
      setSavingId(null)
    }
  }

  const getStatusBadge = (invite: OrganizationInviteResponse) => {
    const isExpired = new Date(invite.expiresAt) < new Date()

    if (invite.status === "CANCELLED") {
      return <Badge variant="destructive">ملغاة</Badge>
    }
    if (invite.status === "EXPIRED" || isExpired) {
      return <Badge variant="secondary">منتهية</Badge>
    }
    if (invite.status === "ACCEPTED") {
      return <Badge variant="default">مقبولة</Badge>
    }
    return <Badge variant="outline">معلقة</Badge>
  }

  const getInviteType = (invite: OrganizationInviteResponse) => {
    const roleLabel = invite.role === "ADMIN" ? "مشرف" : "طالب"

    if (invite.maxUses && invite.maxUses > 1) {
      return (
        <div className="flex items-center gap-1">
          <Users className="h-4 w-4 text-blue-500" />
          <span className="text-sm font-medium">عامة ({roleLabel})</span>
        </div>
      )
    }
    return (
      <div className="flex items-center gap-1">
        <User className="h-4 w-4 text-green-600" />
        <span className="text-sm font-medium">خاصة ({roleLabel})</span>
      </div>
    )
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("ar-SA", {
      year: "numeric",
      month: "short",
      day: "numeric",
    })
  }

  const pendingInvites = invites.filter(
    (inv) => inv.status === "PENDING" && new Date(inv.expiresAt) > new Date()
  )

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      {/* 
        إصلاح التمرير (Scrolling FIX): 
        الـ DialogContent الآن لديه flex-col و overflow-hidden،
        بينما الحاوية الداخلية للجدول هي من تملك overflow-y-auto 
      */}
      <DialogContent
        className="flex max-h-[85vh] max-w-4xl flex-col overflow-hidden p-6"
        dir="rtl"
      >
        <div className="mb-4 flex shrink-0 items-center justify-between">
          <Button
            onClick={fetchInvites}
            variant="outline"
            size="icon"
            disabled={loading}
          >
            <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          </Button>

          <DialogTitle className="flex-1 text-center text-lg">
            الدعوات المعلقة
          </DialogTitle>

          <div className="w-10"></div>
        </div>

        {loading ? (
          <div className="space-y-3">
            {[...Array(3)].map((_, i) => (
              <Skeleton key={i} className="h-12 w-full" />
            ))}
          </div>
        ) : pendingInvites.length === 0 ? (
          <div className="flex-1 py-12 text-center">
            <Clock className="mx-auto h-12 w-12 text-muted-foreground" />
            <p className="mt-4 text-lg text-muted-foreground">
              لا توجد دعوات معلقة حالياً
            </p>
          </div>
        ) : (
          <div className="flex-1 overflow-y-auto rounded-md border shadow-sm">
            <Table>
              <TableHeader className="sticky top-0 z-10 bg-background shadow-sm">
                <TableRow>
                  <TableHead>المستخدم</TableHead>
                  <TableHead>النوع</TableHead>
                  <TableHead>السعة</TableHead>
                  <TableHead>تاريخ الانتهاء</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead>إجراءات</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {pendingInvites.map((invite) => (
                  <TableRow key={invite.id}>
                    <TableCell>
                      <div className="font-medium">
                        {invite.userName || "مستخدم غير معروف"}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        بواسطة: {invite.invitedByName}
                      </div>
                    </TableCell>
                    <TableCell>{getInviteType(invite)}</TableCell>
                    <TableCell>
                      {invite.maxUses > 1 ? (
                        editingId === invite.id ? (
                          <div className="flex items-center gap-2">
                            <Input
                              type="number"
                              min={1}
                              max={100}
                              value={editCapacity}
                              onChange={(e) =>
                                setEditCapacity(parseInt(e.target.value) || 1)
                              }
                              className="h-8 w-20"
                            />
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-8 w-8 text-green-600"
                              onClick={() => handleSaveCapacity(invite.id)}
                              disabled={savingId === invite.id}
                            >
                              {savingId === invite.id ? (
                                <Loader2 className="h-4 w-4 animate-spin" />
                              ) : (
                                <Save className="h-4 w-4" />
                              )}
                            </Button>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-8 w-8"
                              onClick={() => setEditingId(null)}
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </div>
                        ) : (
                          <div className="flex items-center gap-2">
                            <span>
                              {invite.usedCount} / {invite.maxUses}
                            </span>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-8 w-8"
                              onClick={() => handleStartEdit(invite)}
                            >
                              <Pencil className="h-3 w-3" />
                            </Button>
                          </div>
                        )
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1 text-sm">
                        <Clock className="h-3 w-3" />
                        {formatDate(invite.expiresAt)}
                      </div>
                    </TableCell>
                    <TableCell>{getStatusBadge(invite)}</TableCell>
                    <TableCell>
                      {/* تمت إزالة زر إعادة الإرسال من هنا */}
                      <Button
                        size="icon"
                        variant="ghost"
                        className="h-8 w-8 text-destructive hover:bg-destructive/10 hover:text-destructive"
                        onClick={() => handleCancel(invite.id)}
                        disabled={cancellingId === invite.id}
                      >
                        {cancellingId === invite.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <XCircle className="h-4 w-4" />
                        )}
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
