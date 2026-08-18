"use client"

import { useEffect, useState, useTransition } from "react"
import {
  BadgeCheck,
  Building2,
  CheckCircle2,
  Clock3,
  ExternalLink,
  Inbox,
  Loader2,
  XCircle,
} from "lucide-react"
import { toast } from "sonner"

import { OrganizationVerifiedBadge } from "@/components/organization-verified-badge"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Textarea } from "@/components/ui/textarea"
import {
  getOrganizationVerificationsAction,
  reviewOrganizationVerificationAction,
} from "@/lib/actions/admin"
import type {
  OrganizationVerificationResponse,
  OrganizationVerificationStatus,
} from "@/lib/api/types"

type VerificationFilter = OrganizationVerificationStatus | "ALL"

const statusLabels: Record<VerificationFilter, string> = {
  ALL: "الكل",
  PENDING: "قيد الانتظار",
  APPROVED: "تمت الموافقة",
  REJECTED: "مرفوض",
}

export function OrganizationVerificationsPage({
  initialRequests,
  totalElements,
}: {
  initialRequests: OrganizationVerificationResponse[]
  totalElements: number
}) {
  const [requests, setRequests] = useState(initialRequests)
  const [selectedId, setSelectedId] = useState<number | null>(
    initialRequests[0]?.id ?? null
  )
  const [status, setStatus] = useState<VerificationFilter>("PENDING")
  const [isLoading, startLoading] = useTransition()

  const selectedRequest =
    requests.find((request) => request.id === selectedId) ?? null

  function loadStatus(nextStatus: VerificationFilter) {
    setStatus(nextStatus)
    startLoading(async () => {
      try {
        const page = await getOrganizationVerificationsAction(nextStatus, {
          page: 0,
          size: 50,
          sort: ["createdAt,desc"],
        })
        const nextRequests = page.content ?? []
        setRequests(nextRequests)
        setSelectedId(nextRequests[0]?.id ?? null)
      } catch (error) {
        toast.error(
          error instanceof Error
            ? error.message
            : "تعذر تحميل طلبات التوثيق"
        )
      }
    })
  }

  function handleUpdated(updated: OrganizationVerificationResponse) {
    setRequests((current) =>
      current.map((request) => (request.id === updated.id ? updated : request))
    )
  }

  return (
    <div className="flex h-screen min-h-0 flex-col overflow-hidden">
      <header className="shrink-0 border-b bg-card">
        <div className="flex h-16 items-center justify-between gap-4 px-4 md:px-6">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-sky-500/10">
              <BadgeCheck className="h-5 w-5 text-sky-600" />
            </div>

            <div>
              <h1 className="font-bold">توثيق المنظمات</h1>
              <p className="text-xs text-muted-foreground">
                راجع ملفات الإثبات واعتمد شارات توثيق المنظمات
              </p>
            </div>
          </div>

          <div className="hidden rounded-full bg-muted px-3 py-1.5 text-xs font-semibold text-muted-foreground sm:block">
            {totalElements} طلبات
          </div>
        </div>
      </header>

      <div className="flex min-h-0 flex-1">
        <aside className="flex w-full shrink-0 flex-col border-l bg-card md:w-[380px] xl:w-[420px]">
          <div className="shrink-0 border-b p-3">
            <div className="flex flex-wrap gap-2">
              {(["PENDING", "APPROVED", "REJECTED", "ALL"] as const).map(
                (item) => (
                  <Button
                    key={item}
                    size="sm"
                    variant={status === item ? "default" : "outline"}
                    onClick={() => loadStatus(item)}
                    disabled={isLoading}
                  >
                    {statusLabels[item]}
                  </Button>
                )
              )}
            </div>
          </div>

          <div className="min-h-0 flex-1 overflow-y-auto">
            {isLoading ? (
              <div className="flex h-full items-center justify-center">
                <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
              </div>
            ) : requests.length === 0 ? (
              <div className="flex h-full flex-col items-center justify-center p-8 text-center">
                <Inbox className="h-10 w-10 text-muted-foreground/50" />
                <p className="mt-3 text-sm font-semibold">لا توجد طلبات</p>
                <p className="mt-1 text-xs text-muted-foreground">
                  لا توجد طلبات توثيق منظمات لهذا الفلتر.
                </p>
              </div>
            ) : (
              requests.map((request) => (
                <button
                  key={request.id}
                  type="button"
                  onClick={() => setSelectedId(request.id)}
                  className={`flex w-full items-start gap-3 border-b p-4 text-start transition-colors hover:bg-muted/50 ${
                    request.id === selectedId ? "bg-muted" : ""
                  }`}
                >
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10">
                    <Building2 className="h-4 w-4 text-primary" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <p className="truncate text-sm font-semibold">
                        {request.organization.name}
                      </p>
                      {request.organization.verified && (
                        <OrganizationVerifiedBadge />
                      )}
                    </div>
                    <p className="truncate text-xs text-muted-foreground">
                      @{request.organization.slug}
                    </p>
                    <div className="mt-2">
                      <VerificationStatusBadge status={request.status} />
                    </div>
                  </div>
                </button>
              ))
            )}
          </div>
        </aside>

        <section className="hidden min-w-0 flex-1 overflow-y-auto bg-background md:block">
          {selectedRequest ? (
            <VerificationDetails
              key={selectedRequest.id}
              request={selectedRequest}
              onUpdated={handleUpdated}
            />
          ) : (
            <EmptyDetails />
          )}
        </section>
      </div>
    </div>
  )
}

function VerificationDetails({
  request,
  onUpdated,
}: {
  request: OrganizationVerificationResponse
  onUpdated: (request: OrganizationVerificationResponse) => void
}) {
  const [adminNote, setAdminNote] = useState(request.adminNote ?? "")
  const [isSubmitting, startSubmit] = useTransition()

  useEffect(() => {
    setAdminNote(request.adminNote ?? "")
  }, [request.id, request.adminNote])

  function review(status: "APPROVED" | "REJECTED") {
    startSubmit(async () => {
      try {
        const updated = await reviewOrganizationVerificationAction(request.id, {
          status,
          adminNote: adminNote.trim() || null,
        })
        onUpdated(updated)
        toast.success("تم تحديث طلب التوثيق")
      } catch (error) {
        toast.error(
          error instanceof Error
            ? error.message
            : "تعذر تحديث طلب التوثيق"
        )
      }
    })
  }

  return (
    <div className="flex min-w-0 flex-col gap-5 p-4 md:p-6 lg:p-8">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <BadgeCheck className="h-5 w-5 text-sky-600" />
            <p className="text-sm font-semibold text-muted-foreground">
              طلب رقم {request.id}
            </p>
            <VerificationStatusBadge status={request.status} />
          </div>

          <h2 className="mt-2 text-2xl font-extrabold tracking-tight">
            مراجعة توثيق المنظمة
          </h2>
        </div>
      </div>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">المنظمة</CardTitle>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="flex items-center gap-3">
            <Avatar className="h-12 w-12 rounded-lg">
              <AvatarFallback className="rounded-lg">
                {request.organization.name.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <p className="truncate text-sm font-bold">
                  {request.organization.name}
                </p>
                {request.organization.verified && <OrganizationVerifiedBadge />}
              </div>
              <p className="truncate text-xs text-muted-foreground">
                @{request.organization.slug}
              </p>
            </div>
          </div>

          <Separator />

          <div className="grid gap-4 text-sm sm:grid-cols-2">
            <InfoRow label="مقدم الطلب">{request.requestedBy.name}</InfoRow>
            <InfoRow label="الأعضاء">
              {request.organization.membersCount ?? 0}
            </InfoRow>
            <InfoRow label="الكورسات">
              {request.organization.coursesCount ?? 0}
            </InfoRow>
            <InfoRow label="الحالة الحالية">
              <VerificationStatusBadge status={request.status} />
            </InfoRow>
          </div>

          {request.note && (
            <div>
              <p className="text-xs font-bold text-muted-foreground">ملاحظة</p>
              <p className="mt-2 rounded-lg bg-muted/50 p-4 text-sm leading-6">
                {request.note}
              </p>
            </div>
          )}

          <Button
            variant="outline"
            nativeButton={false}
            render={
              <a href={request.proofUrl} target="_blank" rel="noreferrer" />
            }
          >
            <ExternalLink className="ml-2 h-4 w-4" />
            فتح ملف الإثبات
          </Button>
        </CardContent>
      </Card>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">قرار الإدارة</CardTitle>
        </CardHeader>

        <CardContent className="space-y-4">
          <Textarea
            value={adminNote}
            onChange={(event) => setAdminNote(event.target.value)}
            placeholder="أضف ملاحظة إدارية اختيارية..."
            className="min-h-28 resize-y"
          />

          <div className="flex flex-wrap items-center justify-end gap-2">
            <Button
              variant="outline"
              disabled={isSubmitting || request.status === "REJECTED"}
              onClick={() => review("REJECTED")}
            >
              <XCircle className="ml-2 h-4 w-4" />
              رفض
            </Button>

            <Button
              disabled={isSubmitting || request.status === "APPROVED"}
              onClick={() => review("APPROVED")}
            >
              <CheckCircle2 className="ml-2 h-4 w-4" />
              الموافقة والتوثيق
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function VerificationStatusBadge({
  status,
}: {
  status: OrganizationVerificationStatus
}) {
  if (status === "APPROVED") {
    return <OrganizationVerifiedBadge showLabel />
  }

  if (status === "REJECTED") {
    return (
      <Badge variant="destructive" className="gap-1">
        <XCircle className="h-3.5 w-3.5" />
        {statusLabels.REJECTED}
      </Badge>
    )
  }

  return (
    <Badge variant="secondary" className="gap-1">
      <Clock3 className="h-3.5 w-3.5" />
      {statusLabels.PENDING}
    </Badge>
  )
}

function InfoRow({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-bold text-muted-foreground">{label}</p>
      <div className="text-sm font-semibold">{children}</div>
    </div>
  )
}

function EmptyDetails() {
  return (
    <div className="flex h-full flex-col items-center justify-center p-8 text-center">
      <div className="flex h-14 w-14 items-center justify-center rounded-full bg-muted">
        <BadgeCheck className="h-6 w-6 text-muted-foreground" />
      </div>
      <h2 className="mt-4 text-lg font-bold">اختر طلبا للمراجعة</h2>
      <p className="mt-1 max-w-sm text-sm leading-6 text-muted-foreground">
        اختر طلب توثيق منظمة لمراجعة ملف الإثبات وإرسال قرار الإدارة.
      </p>
    </div>
  )
}
