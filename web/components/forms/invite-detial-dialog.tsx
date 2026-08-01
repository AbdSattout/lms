"use client"

import { useState } from "react"
import Image from "next/image"
import {
  X,
  Loader2,
  Check,
  BookOpen,
  Users,
  Shield,
  GraduationCap,
  FileText,
  Map,
  User,
  Calendar,
  Lock,
  Globe,
} from "lucide-react"

import { OrganizationInviteResponse } from "@/lib/api/types"
import { acceptInviteAction, declineInviteAction } from "@/lib/actions/invites"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogDescription,
  DialogHeader,
  DialogFooter,
} from "@/components/ui/dialog"
import { cn } from "@/lib/utils"

interface InviteDetailDialogProps {
  invite: OrganizationInviteResponse | null
  isOpen: boolean
  onClose: () => void
  onAccept?: (invite: OrganizationInviteResponse) => void
  onDecline?: (invite: OrganizationInviteResponse) => void
}

export function InviteDetailDialog({
  invite,
  isOpen,
  onClose,
  onAccept,
  onDecline,
}: InviteDetailDialogProps) {
  const [isProcessing, setIsProcessing] = useState(false)
  const [actionType, setActionType] = useState<"accept" | "decline" | null>(
    null
  )

  const [coverError, setCoverError] = useState(false)
  const [logoError, setLogoError] = useState(false)

  const handleOpenChange = (open: boolean) => {
    if (!open) {
      setCoverError(false)
      setLogoError(false)
      onClose()
    }
  }

  if (!invite) return null
  const { organization, overview, invitedByName, role, expiresAt } = invite

  const handleAccept = async () => {
    if (!invite.token) return
    setIsProcessing(true)
    setActionType("accept")
    const result = await acceptInviteAction(invite.token)
    setIsProcessing(false)
    if (result.success) {
      onAccept?.(invite)
      onClose()
    }
  }

  const handleDecline = async () => {
    if (!invite.token) return
    setIsProcessing(true)
    setActionType("decline")
    const result = await declineInviteAction(invite.token)
    setIsProcessing(false)
    if (result.success) {
      onDecline?.(invite)
      onClose()
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("ar-SA", {
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  const getRoleBadge = (role: string) => {
    switch (role) {
      case "ADMIN":
        return {
          label: "مشرف",
          color:
            "bg-purple-100 text-purple-700 dark:bg-purple-500/10 border-purple-500/20 dark:text-purple-400",
        }
      case "STUDENT":
        return {
          label: "طالب",
          color:
            "bg-blue-100 text-blue-700 dark:bg-blue-500/10 border-blue-500/20 dark:text-blue-400",
        }
      default:
        return {
          label: role,
          color:
            "bg-gray-100 text-gray-700 dark:bg-gray-500/10 border-gray-500/20 dark:text-gray-400",
        }
    }
  }
  const roleBadge = getRoleBadge(role)

  const stats = [
    {
      label: "الأعضاء",
      value: overview?.membersCount || 0,
      icon: Users,
      iconColor: "text-green-600 dark:text-green-500",
      bgClass:
        "bg-green-100/70 dark:bg-green-500/10 border-green-200 dark:border-green-500/20",
    },
    {
      label: "المشرفين",
      value: overview?.adminsCount || 0,
      icon: Shield,
      iconColor: "text-purple-600 dark:text-purple-500",
      bgClass:
        "bg-purple-100/70 dark:bg-purple-500/10 border-purple-200 dark:border-purple-500/20",
    },
    {
      label: "الطلاب",
      value: overview?.studentsCount || 0,
      icon: GraduationCap,
      iconColor: "text-blue-600 dark:text-blue-500",
      bgClass:
        "bg-blue-100/70 dark:bg-blue-500/10 border-blue-200 dark:border-blue-500/20",
    },
    {
      label: "الدورات",
      value: overview?.coursesCount || 0,
      icon: BookOpen,
      iconColor: "text-orange-600 dark:text-orange-500",
      bgClass:
        "bg-orange-100/70 dark:bg-orange-500/10 border-orange-200 dark:border-orange-500/20",
    },
    {
      label: "المسارات",
      value: overview?.roadmapsCount || 0,
      icon: Map,
      iconColor: "text-teal-600 dark:text-teal-500",
      bgClass:
        "bg-teal-100/70 dark:bg-teal-500/10 border-teal-200 dark:border-teal-500/20",
    },
    {
      label: "المنشورات",
      value: overview?.postsCount || 0,
      icon: FileText,
      iconColor: "text-pink-600 dark:text-pink-500",
      bgClass:
        "bg-pink-100/70 dark:bg-pink-500/10 border-pink-200 dark:border-pink-500/20",
    },
  ]

  const firstLetter = organization?.name
    ? organization.name.charAt(0).toUpperCase()
    : "O"

  return (
    <Dialog open={isOpen} onOpenChange={handleOpenChange}>
      <DialogContent className="flex max-h-[85vh] max-w-[34rem] flex-col gap-0 overflow-hidden bg-background p-0 shadow-2xl outline-none sm:rounded-2xl [&>button]:hidden">
        <DialogHeader className="sr-only">
          <DialogTitle>دعوة الانضمام</DialogTitle>
          <DialogDescription>مراجعة الدعوة</DialogDescription>
        </DialogHeader>

        <button
          onClick={onClose}
          className="absolute top-3 right-3 left-auto z-50 flex h-8 w-8 items-center justify-center rounded-full border border-white/10 bg-black/40 text-white shadow-md backdrop-blur-md transition-all outline-none hover:bg-black/60 active:scale-95 rtl:start-auto rtl:end-auto rtl:right-auto rtl:left-3"
        >
          <X className="h-4 w-4 shrink-0" />
        </button>

        <div className="relative z-0 no-scrollbar flex w-full flex-1 shrink flex-col overflow-x-hidden overflow-y-auto bg-background pt-0 pb-8">
          <div className="relative flex h-36 w-full shrink-0 items-center justify-center overflow-hidden rounded-t-xl bg-gradient-to-br from-indigo-900/60 via-zinc-900 to-black sm:rounded-t-2xl">
            {organization?.imageUrl && !coverError && (
              <Image
                src={organization.imageUrl}
                alt="Banner"
                fill
                className="object-cover opacity-50 mix-blend-screen"
                priority
                sizes="(max-width: 600px) 100vw, 34rem"
                onError={() => setCoverError(true)}
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-background/90 to-transparent/10" />
          </div>

          <div className="relative z-10 -mt-[44px] mb-4 flex w-full shrink-0 flex-col items-center justify-center px-6">
            <div className="relative z-10 mx-auto flex h-[88px] w-[88px] items-center justify-center overflow-hidden rounded-full border border-border bg-muted shadow-lg ring-4 ring-background">
              {organization?.imageUrl && !logoError ? (
                <Image
                  src={organization.imageUrl}
                  alt=""
                  fill
                  className="object-cover"
                  sizes="90px"
                  onError={() => setLogoError(true)}
                />
              ) : (
                <span className="text-3xl font-extrabold text-foreground uppercase">
                  {firstLetter}
                </span>
              )}
            </div>

            <h2 className="mt-4 line-clamp-1 w-full max-w-[85%] text-center text-xl font-bold tracking-tight text-foreground sm:text-2xl">
              {organization?.name || "منظمة"}
            </h2>
            {organization?.description && (
              <p className="mt-1 line-clamp-2 w-full max-w-[90%] text-center text-sm text-muted-foreground">
                {organization.description}
              </p>
            )}

            <div className="mx-auto mt-3 flex w-full max-w-sm flex-wrap items-center justify-center gap-2 text-center">
              <Badge
                className={cn(
                  "rounded-full bg-transparent text-xs font-medium shadow-sm",
                  roleBadge.color
                )}
              >
                صلاحيتك: {roleBadge.label}
              </Badge>
              {organization?.visibility && (
                <Badge
                  variant="secondary"
                  className="rounded-full border-0 bg-muted/60 text-xs font-medium opacity-80 hover:bg-muted/80"
                >
                  {organization.visibility === "PRIVATE" ? (
                    <Lock className="ml-1.5 h-3.5 w-3.5" />
                  ) : (
                    <Globe className="ml-1.5 h-3.5 w-3.5" />
                  )}
                  {organization.visibility === "PRIVATE"
                    ? "مساحة خاصة"
                    : "عامة للجميع"}
                </Badge>
              )}
            </div>
          </div>

          <Separator className="mx-6 mb-5 w-auto flex-shrink-0 bg-border/60 opacity-70" />

          <div className="w-full px-5">
            <h3 className="start mb-4 px-1 text-sm font-semibold tracking-wide text-foreground/70">
              الإحصائيات للمنظمة
            </h3>
            <div className="grid grid-cols-2 gap-3 text-start sm:grid-cols-3">
              {stats.map((stat) => (
                <div
                  key={stat.label}
                  className={cn(
                    "flex cursor-default flex-col gap-2 rounded-2xl border p-4 transition-all duration-300 hover:opacity-85",
                    stat.bgClass
                  )}
                >
                  <div className="flex w-full items-center justify-between">
                    <span className="text-[13px] font-semibold tracking-wide text-muted-foreground">
                      {stat.label}
                    </span>
                    <stat.icon
                      className={cn(
                        "h-[18px] w-[18px] opacity-80",
                        stat.iconColor
                      )}
                    />
                  </div>
                  <p className="mt-1.5 flex truncate text-[26px] leading-none font-black text-foreground drop-shadow-sm">
                    {stat.value.toLocaleString("ar-SA")}
                  </p>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-8 mb-2 grid w-full shrink-0 grid-cols-1 gap-4 px-5">
            <div className="flex flex-1 shrink-0 flex-col gap-3 rounded-2xl border border-border/80 bg-muted/15 p-4">
              <div className="flex items-center gap-2 text-sm font-medium whitespace-nowrap">
                <span className="inline-flex items-center justify-center rounded border border-white/5 bg-muted-foreground/10 p-1 opacity-50">
                  <User className="h-4 w-4" />
                </span>
                <span className="text-muted-foreground">صاحب الدعوة:</span>
                <span className="text-[15px] font-semibold tracking-wide text-foreground">
                  {invitedByName}
                </span>
              </div>
              <div className="flex items-center gap-2 text-sm font-medium whitespace-nowrap">
                <span className="inline-flex items-center justify-center rounded border border-white/5 bg-muted-foreground/10 p-1 opacity-50">
                  <Calendar className="h-4 w-4" />
                </span>
                <span className="text-muted-foreground">صلاحية الرد للـ:</span>
                <span className="tracking-wide text-foreground">
                  {formatDate(expiresAt)}
                </span>
              </div>
            </div>

            {organization?.owner && (
              <div className="flex min-w-[200px] flex-1 shrink-0 items-center gap-3 overflow-hidden rounded-2xl border border-border/80 bg-muted/15 p-3 px-4 text-start">
                <div className="relative z-10 flex h-[46px] w-[46px] shrink-0 items-center justify-center overflow-hidden rounded-full border bg-zinc-800 shadow-sm ring-[2.5px] ring-muted-foreground/20">
                  {organization.owner.picture ? (
                    <Image
                      src={organization.owner.picture}
                      alt=""
                      fill
                      className="z-20 object-cover"
                    />
                  ) : (
                    <User className="z-20 h-5 w-5 text-muted-foreground" />
                  )}
                </div>
                <div className="flex w-full min-w-[50px] flex-shrink flex-col truncate text-start text-clip">
                  <p className="mb-[3px] truncate overflow-hidden text-[11px] leading-none font-semibold whitespace-nowrap text-muted-foreground uppercase opacity-80">
                    المالك
                  </p>
                  <p className="line-clamp-1 min-w-0 truncate text-sm leading-tight font-bold tracking-wide break-all text-clip text-foreground">
                    {organization.owner.name}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="relative z-20 flex w-full shrink-0 flex-col-reverse items-center gap-2.5 rounded-b-2xl border-t border-border/70 bg-background p-5 shadow-[0_-5px_18px_-15px_rgba(0,0,0,0.5)] sm:flex-row">
          <Button
            onClick={handleDecline}
            disabled={isProcessing}
            variant="outline"
            className="flex h-14 w-full items-center gap-2 rounded-2xl border-border/80 bg-background text-[15px] font-semibold tracking-wide text-foreground opacity-95 transition-all hover:-translate-y-[1px] hover:border-red-500/30 hover:bg-red-500/10 hover:text-red-500 active:scale-[0.98] sm:max-w-[32%]"
          >
            {isProcessing && actionType === "decline" ? (
              <Loader2 className="h-4 w-4 shrink-0 animate-spin" />
            ) : (
              <X className="h-4.5 w-4.5 shrink-0 opacity-70" />
            )}
            رفض
          </Button>

          <Button
            onClick={handleAccept}
            disabled={isProcessing}
            className="flex h-14 w-full flex-1 items-center justify-center gap-2 rounded-2xl border-b-[3px] border-black/25 bg-teal-600 text-base font-bold text-white shadow-md transition-all hover:-translate-y-[2px] hover:bg-teal-500 focus:ring-4 focus:ring-teal-500/20 focus:outline-none active:scale-[0.98] active:border-b-0"
          >
            {isProcessing && actionType === "accept" ? (
              <Loader2 className="h-5 w-5 animate-spin" />
            ) : (
              <Check className="h-5 w-5" />
            )}
            تأكيد إستقبال الدعوة
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
