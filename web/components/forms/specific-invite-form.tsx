"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Skeleton } from "@/components/ui/skeleton"
import { Search, UserPlus, ArrowRight, Loader2, Check } from "lucide-react"
import { toast } from "sonner"
import { Role, ProfileResponse } from "@/lib/api/types"
import { useDebounce } from "@/hooks/use-debounce"
import { searchUsers, createInvite } from "@/lib/actions/members"

export function SpecificInviteForm({
  slug,
  role,
  onBack,
}: {
  slug: string
  role: Role
  onBack: () => void
}) {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState<ProfileResponse[]>([])
  const [loading, setLoading] = useState(false)
  const [selectedUser, setSelectedUser] = useState<ProfileResponse | null>(null)
  const [inviting, setInviting] = useState(false)
  const [invited, setInvited] = useState(false)

  const debouncedQuery = useDebounce(query, 300)

  useEffect(() => {
    const search = async () => {
      if (debouncedQuery.length < 2) {
        setResults([])
        return
      }
      setLoading(true)
      try {
        const users = await searchUsers(debouncedQuery)
        setResults(users ?? [])
      } catch (error) {
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
          errMessage.includes("already a member") ||
          errMessage.includes("400")
        ) {
          toast.error("هذا المستخدم عضو بالفعل في هذه المؤسسة")
        } else if (
          errMessage.includes("already") ||
          errMessage.includes("400")
        ) {
          toast.error("هذا المستخدم يمتلك دعوة نشطة مسبقاً")
        } else {
          toast.error("تعذر إرسال الدعوة في الوقت الحالي")
        }
        return
      }

      setInvited(true)
      toast.success(`تم إرسال الدعوة إلى ${selectedUser.name} بنجاح`)
    } catch {
      toast.error("حدث خطأ بالاتصال، يرجى المحاولة لاحقاً")
    } finally {
      setInviting(false)
    }
  }

  if (invited) {
    return (
      <div className="flex h-full animate-in flex-col justify-center space-y-5 p-8 text-center duration-500 fade-in-0">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
          <Check className="h-8 w-8 text-green-600 dark:text-green-400" />
        </div>
        <div>
          <p className="text-xl font-medium text-foreground">
            اكتملت العملية بنجاح!
          </p>
          <p className="mt-2 text-sm text-muted-foreground">
            تم تسجيل طلب الانضمام.
          </p>
        </div>
        <Button
          onClick={onBack}
          variant="outline"
          className="mt-4 w-full gap-2"
        >
          <ArrowRight className="h-4 w-4" />
          العودة للقائمة الرئيسية
        </Button>
      </div>
    )
  }

  return (
    <div className="flex h-full flex-col space-y-4 bg-background p-4">
      {!selectedUser ? (
        <>
          <div className="relative shrink-0 rounded-md shadow-sm transition-all focus-within:ring-2 focus-within:ring-primary">
            <Search className="absolute top-3 right-3 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="البحث بالاسم أو البريد الالكتروني..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="h-10 border-0 pr-9 ring-1 ring-border/60"
            />
          </div>

          <div className="custom-scrollbar flex-1 overflow-y-auto rounded-md border bg-muted/20">
            {loading ? (
              <div className="space-y-4 p-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="flex items-center gap-3">
                    <Skeleton className="h-11 w-11 shrink-0 rounded-full" />
                    <div className="flex-1 space-y-2">
                      <Skeleton className="h-4 w-1/3" />
                      <Skeleton className="h-3 w-1/2" />
                    </div>
                  </div>
                ))}
              </div>
            ) : results.length > 0 ? (
              <div className="space-y-1 p-2">
                {results.map((user) => (
                  <div
                    key={user.user.id}
                    onClick={() => setSelectedUser(user)}
                    className="flex cursor-pointer items-center gap-4 rounded-lg border border-transparent p-3 shadow-sm transition-colors hover:border-border/60 hover:bg-background hover:shadow active:scale-[0.99]"
                  >
                    <Avatar className="h-11 w-11 shrink-0 ring-1 ring-border">
                      <AvatarImage src={user.user.picture} alt={user.name} />
                      <AvatarFallback>
                        {user.name?.charAt(0) || "?"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 truncate">
                      <p className="text-sm font-semibold text-foreground">
                        {user.name}
                      </p>
                      <p className="mt-0.5 truncate text-xs text-muted-foreground">
                        {user.email}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : query.length >= 2 ? (
              <div className="flex h-full animate-in flex-col items-center justify-center p-2 text-center text-sm text-muted-foreground duration-300 fade-in-0">
                <Search className="mb-2 h-8 w-8 text-muted-foreground/30" />
                <p>لا توجد نتائج مطابقة لبحثك</p>
              </div>
            ) : (
              <div className="flex h-full flex-col items-center justify-center p-2 text-center text-sm text-muted-foreground/70">
                أدخل اسم مستخدم لبدء البحث وتخصيص دعوة له
              </div>
            )}
          </div>
        </>
      ) : (
        <div className="flex h-full animate-in flex-col justify-center space-y-8 px-2 duration-300 slide-in-from-right-4">
          <div className="flex flex-col items-center gap-4 rounded-xl border bg-gradient-to-br from-muted/30 to-background p-6 shadow-sm">
            <Avatar className="h-20 w-20 shadow-md ring-4 ring-background">
              <AvatarImage
                src={selectedUser.user.picture}
                alt={selectedUser.user.name}
              />
              <AvatarFallback className="text-xl">
                {selectedUser.name?.charAt(0) || "?"}
              </AvatarFallback>
            </Avatar>
            <div className="overflow-hidden text-center">
              <h3 className="truncate text-lg font-bold text-foreground">
                {selectedUser.name}
              </h3>
              <p className="truncate text-sm text-muted-foreground">
                {selectedUser.email}
              </p>
            </div>
          </div>

          <div className="mt-4 flex w-full gap-3">
            <Button
              onClick={() => setSelectedUser(null)}
              variant="outline"
              className="h-11 w-full basis-1/3 text-muted-foreground"
            >
              <ArrowRight className="ml-2 h-4 w-4" /> تراجع
            </Button>
            <Button
              onClick={handleInvite}
              disabled={inviting}
              className="h-11 w-full basis-2/3"
            >
              {inviting ? (
                <Loader2 className="ml-2 h-4 w-4 animate-spin" />
              ) : (
                <UserPlus className="ml-2 h-4 w-4" />
              )}
              {inviting ? "يتم تأكيد الطلب..." : "تأكيد وإرسال"}
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
