"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
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
  Search,
  UserPlus,
  Users,
  ArrowRight,
  Loader2,
  Check,
  Copy,
  Clock,
  XCircle,
  Pencil,
  Save,
  X,
} from "lucide-react"
import { toast } from "sonner"

import {
  Role,
  OrganizationInviteResponse,
  ProfileResponse,
} from "@/lib/api/types"
import { useDebounce } from "@/hooks/use-debounce"
import {
  createInvite,
  createPublicInvite,
  searchUsers,
  getPendingInvites,
  cancelInvite,
  updateInviteCapacity,
} from "@/lib/actions/members"

interface AddMemberFormProps {
  slug: string
  role: Role
  onBack: () => void
}
export function AddMemberForm({ slug, role, onBack }: AddMemberFormProps) {
  return (
    <Tabs
      defaultValue="specific"
      className="flex h-full w-full flex-col overflow-hidden"
    >
      {/* 1. Make grid columns dynamic based on role */}
      <TabsList
        className={`grid h-auto w-full shrink-0 bg-muted p-1 ${
          role === "ADMIN" ? "grid-cols-2" : "grid-cols-3"
        }`}
      >
        <TabsTrigger value="specific" className="gap-2 py-2">
          <UserPlus className="h-4 w-4" />
          <span className="hidden sm:inline">دعوة محددة</span>
          <span className="sm:hidden">محددة</span>
        </TabsTrigger>

        {/* 2. Hide the Public Invite trigger if role is ADMIN */}
        {role !== "ADMIN" && (
          <TabsTrigger value="public" className="gap-2 py-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">دعوة عامة</span>
            <span className="sm:hidden">عامة</span>
          </TabsTrigger>
        )}

        <TabsTrigger value="pending" className="gap-2 py-2">
          <Clock className="h-4 w-4" />
          <span className="hidden sm:inline">دعوات معلقة</span>
          <span className="sm:hidden">معلقة</span>
        </TabsTrigger>
      </TabsList>

      <div className="mt-4 flex flex-1 flex-col overflow-hidden rounded-md border shadow-sm">
        <TabsContent
          value="specific"
          className="m-0 flex flex-1 flex-col overflow-hidden focus-visible:outline-none"
        >
          <SpecificInviteForm slug={slug} role={role} onBack={onBack} />
        </TabsContent>

        {/* 3. Hide the Public Invite content if role is ADMIN */}
        {role !== "ADMIN" && (
          <TabsContent
            value="public"
            className="m-0 flex flex-1 flex-col overflow-hidden focus-visible:outline-none"
          >
            <PublicInviteForm slug={slug} role={role} onBack={onBack} />
          </TabsContent>
        )}

        <TabsContent
          value="pending"
          className="m-0 flex flex-1 flex-col overflow-hidden focus-visible:outline-none"
        >
          <PendingInvitesList slug={slug} role={role} />
        </TabsContent>
      </div>
    </Tabs>
  )
}
function SpecificInviteForm({ slug, role, onBack }: AddMemberFormProps) {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState<ProfileResponse[]>([])
  const [loading, setLoading] = useState(false)
  const [selectedUser, setSelectedUser] = useState<ProfileResponse | null>(null)
  const [inviting, setInviting] = useState(false)
  const [invited, setInvited] = useState(false)

  const debouncedQuery = useDebounce(query, 300)

  useEffect(() => {
    if (!debouncedQuery || debouncedQuery.length < 2) {
      setResults([])
      return
    }

    const search = async () => {
      setLoading(true)
      try {
        const users = await searchUsers(debouncedQuery)
        setResults(users ?? [])
      } catch (error) {
        console.error("Search failed:", error)
        toast.error("فشل البحث عن المستخدمين")
      } finally {
        setLoading(false)
      }
    }
    search()
  }, [debouncedQuery])
  const handleInvite = async () => {
    if (!selectedUser) return

    setInviting(true)
    try {
      const response = await createInvite(slug, {
        userId: selectedUser.user.id,
        role: role,
      })

      if (!response.success) {
        const errMessage = response.error || ""
        if (
          errMessage.includes("User already invited") ||
          errMessage.includes("400")
        ) {
          toast.error("هذا المستخدم يمتلك دعوة نشطة ")
        } else {
          toast.error("فشل في إرسال الدعوة")
        }
        return
      }

      setInvited(true)
      toast.success(`تم إرسال الدعوة إلى ${selectedUser.name}`)
    } catch {
      toast.error("تعذر الاتصال حاول مجددا")
    } finally {
      setInviting(false)
    }
  }
  if (invited) {
    return (
      <div className="flex h-full flex-col justify-center space-y-4 p-8 text-center">
        <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
          <Check className="h-6 w-6 text-green-600 dark:text-green-400" />
        </div>
        <p className="text-lg font-medium text-foreground">
          تم إرسال الدعوة بنجاح
        </p>
        <Button
          onClick={onBack}
          variant="outline"
          className="mt-4 w-full gap-2"
        >
          <ArrowRight className="h-4 w-4" />
          العودة للقائمة
        </Button>
      </div>
    )
  }

  return (
    <div className="flex h-full flex-col space-y-4 p-2">
      {!selectedUser ? (
        <>
          <div className="relative shrink-0">
            <Search className="absolute top-2.5 right-3 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="ابحث بالاسم، البريد أو المعرف..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="h-10 pr-9"
            />
          </div>

          <div className="custom-scrollbar flex-1 overflow-y-auto rounded-md border bg-background p-1">
            {loading ? (
              <div className="space-y-3 p-2">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="flex items-center gap-3">
                    <Skeleton className="h-10 w-10 shrink-0 rounded-full" />
                    <div className="flex-1 space-y-2">
                      <Skeleton className="h-4 w-1/3" />
                      <Skeleton className="h-3 w-1/2" />
                    </div>
                  </div>
                ))}
              </div>
            ) : results.length > 0 ? (
              <div className="space-y-1">
                {results.map((user) => (
                  <div
                    key={user.user.id}
                    onClick={() => setSelectedUser(user)}
                    className="flex cursor-pointer items-center gap-3 rounded-lg p-2 transition-colors hover:bg-muted"
                  >
                    <Avatar className="h-10 w-10 shrink-0">
                      <AvatarImage src={user.user.picture} alt={user.name} />
                      <AvatarFallback>
                        {user.name?.charAt(0) || "?"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 truncate text-sm text-foreground">
                      <p className="font-semibold">{user.name}</p>
                      <p className="truncate text-xs text-muted-foreground">
                        {user.email}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : query.length >= 2 ? (
              <div className="flex h-full flex-col items-center justify-center p-2 text-center text-sm text-muted-foreground">
                <Search className="mb-2 h-6 w-6 text-muted-foreground/30" />
                لا توجد نتائج مطابقة لبحثك
              </div>
            ) : null}
          </div>
        </>
      ) : (
        <div className="flex h-full flex-col justify-center space-y-6">
          <div className="flex items-center gap-4 rounded-lg border bg-muted p-4 shadow-sm">
            <Avatar className="h-16 w-16 shrink-0">
              <AvatarImage
                src={selectedUser.user.picture}
                alt={selectedUser.user.name}
              />
              <AvatarFallback>
                {selectedUser.name?.charAt(0) || "?"}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 overflow-hidden text-sm">
              <h3 className="truncate text-base font-bold text-foreground">
                {selectedUser.name}
              </h3>
              <p className="truncate text-muted-foreground">
                {selectedUser.email}
              </p>
            </div>
          </div>

          <div className="flex w-full gap-2">
            <Button
              onClick={() => setSelectedUser(null)}
              variant="outline"
              className="h-12 flex-1 gap-2"
            >
              <ArrowRight className="h-4 w-4" /> تراجع
            </Button>
            <Button
              onClick={handleInvite}
              disabled={inviting}
              className="h-12 flex-1 gap-2 bg-blue-600 text-white hover:bg-blue-700"
            >
              {inviting ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <UserPlus className="h-4 w-4" />
              )}
              {inviting ? "جاري الإرسال..." : "تأكيد وإرسال"}
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}

function PublicInviteForm({ slug, role, onBack }: AddMemberFormProps) {
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
      setInviteLink(
        `${window.location.origin}/invite/${result.token ?? result.id}`
      )
      toast.success("تم إنشاء رابط الدعوة بنجاح")
    } catch (error) {
      console.error("Failed to create public invite:", error)
      toast.error("فشل إنشاء الرابط")
    } finally {
      setInviting(false)
    }
  }

  return (
    <div className="flex h-full flex-col p-4">
      {!inviteLink ? (
        <div className="flex h-full flex-1 flex-col pt-10">
          <div className="space-y-3 text-sm">
            <Label
              htmlFor="maxUses"
              className="block text-center text-base font-semibold text-foreground"
            >
              الحد الأقصى للإستخدامات (السعة)
            </Label>
            <Input
              id="maxUses"
              type="number"
              min={1}
              max={100}
              value={maxUses}
              className="h-12 text-center text-lg"
              onChange={(e) => setMaxUses(parseInt(e.target.value) || 1)}
            />
          </div>
          <div className="block flex flex-1 flex-col-reverse justify-end">
            <Button
              onClick={handleCreatePublicInvite}
              disabled={inviting}
              className="mb-4 h-12 w-full gap-2"
            >
              {inviting ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Users className="h-4 w-4" />
              )}
              {inviting ? "جاري الإنشاء..." : "إنشاء رابط دعوة جماعي"}
            </Button>
          </div>
        </div>
      ) : (
        <div className="flex flex-col space-y-6 pt-10 text-sm text-foreground">
          <div className="rounded-lg border bg-background p-6 text-center shadow-sm">
            <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
              <Check className="h-7 w-7 text-green-600 dark:text-green-400" />
            </div>
            <p className="mb-6 text-base font-semibold">
              الرابط جاهز للنسخ الآن
            </p>

            <div className="flex gap-2">
              <Input
                value={inviteLink}
                readOnly
                dir="ltr"
                className="h-11 truncate bg-muted text-left font-mono text-xs focus-visible:ring-1"
              />
              <Button
                onClick={() => {
                  navigator.clipboard.writeText(inviteLink)
                  toast.success("تم النسخ!")
                }}
                size="icon"
                className="h-11 w-11 shrink-0"
              >
                <Copy className="h-5 w-5" />
              </Button>
            </div>
          </div>

          <Button
            onClick={onBack}
            variant="outline"
            className="mt-4 h-11 w-full gap-2"
          >
            <ArrowRight className="h-4 w-4" /> إغلاق وتراجع للوراء
          </Button>
        </div>
      )}
    </div>
  )
}

// ============== ( 3 ) القائمة الداخلية: جدول الدعوات ==============
function PendingInvitesList({ slug, role }: { slug: string; role: Role }) {
  const [invites, setInvites] = useState<OrganizationInviteResponse[]>([])
  const [loading, setLoading] = useState(true)
  const [cancellingId, setCancellingId] = useState<number | null>(null)
  const [editingId, setEditingId] = useState<number | null>(null)
  const [editCapacity, setEditCapacity] = useState<number>(0)
  const [savingId, setSavingId] = useState<number | null>(null)

  const fetchInvites = async () => {
    setLoading(true)
    try {
      const data = await getPendingInvites(slug)

      const filtered = (data ?? []).filter(
        (inv) => inv.role === role && inv.status === "PENDING"
      )
      setInvites(filtered)
    } catch (error) {
      console.error("Failed to fetch pending invites:", error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchInvites()
  }, [slug, role])

  const handleCancel = async (inviteId: number) => {
    setCancellingId(inviteId)
    try {
      await cancelInvite(slug, inviteId)
      setInvites(invites.filter((inv) => inv.id !== inviteId))
      toast.success("تم الإلغاء بنجاح")
    } catch {
      toast.error("حدث خطأ عند المحاولة")
    } finally {
      setCancellingId(null)
    }
  }

  const handleStartEdit = (invite: OrganizationInviteResponse) => {
    if (invite.maxUses) {
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
      toast.success("تم تحديث سعة الدعوة بنجاح")
    } catch (error) {
      toast.error("فشل عملية التحديث")
    } finally {
      setSavingId(null)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("ar-SA", {
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  if (loading) {
    return (
      <div className="flex h-full flex-col justify-center space-y-3 p-4">
        {[...Array(4)].map((_, i) => (
          <Skeleton key={i} className="h-12 w-full rounded" />
        ))}
      </div>
    )
  }

  if (invites.length === 0) {
    return (
      <div className="flex h-full flex-col items-center justify-center space-y-4 p-8 text-center">
        <Clock className="h-10 w-10 text-muted-foreground/30" />
        <p className="text-sm font-semibold text-muted-foreground">
          قائمة الدعوات النَشِطة الحالية لهذا التصنيف تبدو فارغة.
        </p>
      </div>
    )
  }

  return (
    <div className="flex h-full flex-col">
      {/* 
         الإعتماد الجوهري للحد من تجاوز الشاشة يقع على كاهل الفئتين : flex-1 & overflow-auto  
         حيث تم تخصيص الشكرلة فقط على مستوى الجدول!
      */}
      <div className="custom-scrollbar flex-1 overflow-auto bg-background p-0">
        <Table className="w-full text-sm">
          <TableHeader className="sticky top-0 z-10 bg-background/95 backdrop-blur">
            <TableRow>
              <TableHead className="w-1/3 text-right">
                المُرسل إليه / المُرسل
              </TableHead>
              <TableHead className="w-20 text-center whitespace-nowrap">
                النوع
              </TableHead>
              <TableHead className="w-32 text-center whitespace-nowrap">
                الاستخدام
              </TableHead>
              <TableHead className="w-24 text-center whitespace-nowrap">
                الإنتهاء
              </TableHead>
              <TableHead className="sticky top-0 w-10 text-center"></TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {invites.map((invite) => {
              const isSpecific = invite.maxUses === null

              return (
                <TableRow key={invite.id} className="h-14">
                  {/* عمود صاحب الدعوة واسم الداعي */}
                  <TableCell className="w-1/3 text-right align-middle">
                    <p
                      className="w-full truncate font-semibold text-foreground"
                      title={invite.userName || "للعامة"}
                    >
                      {invite.userName || "رابط عام"}
                    </p>
                    <p className="mt-1 truncate text-xs text-muted-foreground opacity-80">
                      المُشرف: {invite.invitedByName}
                    </p>
                  </TableCell>

                  {/* النوع */}
                  <TableCell className="text-center align-middle whitespace-nowrap">
                    {!isSpecific ? (
                      <Badge
                        variant="outline"
                        className="border-green-200 bg-green-50 text-[10px] text-green-700 hover:bg-green-100"
                      >
                        رابط
                      </Badge>
                    ) : (
                      <Badge
                        variant="outline"
                        className="border-blue-200 bg-blue-50 text-[10px] text-blue-700 hover:bg-blue-100"
                      >
                        محدد
                      </Badge>
                    )}
                  </TableCell>

                  {/* الاستخدام مع خانات الإيديت (Tailwind Clean Design) */}
                  <TableCell className="w-32 p-0 text-center align-middle font-mono whitespace-nowrap">
                    {!isSpecific ? (
                      editingId === invite.id ? (
                        <div className="my-1 flex flex-wrap items-center justify-center gap-1 px-1">
                          <Input
                            type="number"
                            min={invite.usedCount + 1}
                            max={1000}
                            value={editCapacity}
                            onChange={(e) =>
                              setEditCapacity(parseInt(e.target.value) || 1)
                            }
                            className="h-8 w-14 border-neutral-300 px-1 text-center text-xs focus-visible:ring-1"
                          />
                          <div className="flex flex-col gap-0">
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-5 w-5 rounded text-green-600 hover:bg-green-100"
                              onClick={() => handleSaveCapacity(invite.id)}
                              disabled={savingId === invite.id}
                            >
                              {savingId === invite.id ? (
                                <Loader2 className="h-3 w-3 animate-spin" />
                              ) : (
                                <Save className="h-3 w-3" />
                              )}
                            </Button>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="h-5 w-5 rounded text-red-500 hover:bg-red-50"
                              onClick={() => setEditingId(null)}
                            >
                              <X className="h-3 w-3" />
                            </Button>
                          </div>
                        </div>
                      ) : (
                        <div className="group flex cursor-default items-center justify-center gap-1 rounded-md p-1 transition-colors hover:bg-muted/30">
                          <span
                            className="rounded bg-muted/60 px-2 py-0.5 text-[12px] font-semibold whitespace-pre"
                            dir="ltr"
                          >
                            {invite.usedCount} / {invite.maxUses}
                          </span>
                          <Button
                            size="icon"
                            variant="ghost"
                            className="h-6 w-6 shrink-0 text-muted-foreground opacity-0 group-hover:opacity-100 hover:text-foreground"
                            onClick={() => handleStartEdit(invite)}
                          >
                            <Pencil className="h-3 w-3" />
                          </Button>
                        </div>
                      )
                    ) : (
                      <span className="block px-2 font-semibold text-muted-foreground/40">
                        -
                      </span>
                    )}
                  </TableCell>

                  <TableCell className="w-24 text-center align-middle text-sm font-medium whitespace-nowrap text-foreground opacity-80">
                    {formatDate(invite.expiresAt)}
                  </TableCell>

                  <TableCell className="w-10 px-2 text-center align-middle">
                    <Button
                      size="icon"
                      variant="ghost"
                      className="hover:text-destructive-foreground h-8 w-8 text-destructive/80 transition-transform hover:scale-105 hover:bg-destructive active:scale-95"
                      title="تعطيل هذه الدعوة بالكامل"
                      onClick={() => handleCancel(invite.id)}
                      disabled={cancellingId === invite.id}
                    >
                      {cancellingId === invite.id ? (
                        <Loader2 className="h-4 w-4 animate-spin opacity-50" />
                      ) : (
                        <XCircle className="h-4 w-4 stroke-[2]" />
                      )}
                    </Button>
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
