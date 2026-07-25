// components/overview/add-member-form.tsx
"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Search,
  UserPlus,
  Users,
  ArrowRight,
  Loader2,
  Check,
  Copy,
} from "lucide-react"
import { toast } from "sonner"

import { Role, UserSearchResponse } from "@/lib/api/types"
import { useDebounce } from "@/hooks/use-debounce"
import {
  createInvite,
  createPublicInvite,
  searchUsers,
} from "@/lib/actions/members"

interface AddMemberFormProps {
  slug: string
  role: Role
  onBack: () => void
}

export function AddMemberForm({ slug, role, onBack }: AddMemberFormProps) {
  return (
    <Tabs defaultValue="specific" className="w-full">
      <TabsList className="grid w-full grid-cols-2">
        <TabsTrigger value="specific" className="gap-2">
          <UserPlus className="h-4 w-4" />
          دعوة محددة
        </TabsTrigger>
        <TabsTrigger value="public" className="gap-2">
          <Users className="h-4 w-4" />
          دعوة عامة
        </TabsTrigger>
      </TabsList>

      <TabsContent value="specific">
        <SpecificInviteForm slug={slug} role={role} onBack={onBack} />
      </TabsContent>

      <TabsContent value="public">
        <PublicInviteForm slug={slug} role={role} onBack={onBack} />
      </TabsContent>
    </Tabs>
  )
}

// Specific Invite Form
function SpecificInviteForm({ slug, role, onBack }: AddMemberFormProps) {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState<UserSearchResponse[]>([])
  const [loading, setLoading] = useState(false)
  const [selectedUser, setSelectedUser] = useState<UserSearchResponse | null>(
    null
  )
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
        toast.error("فشل في البحث عن المستخدمين")
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
      await createInvite(slug, {
        userId: selectedUser.id,
        role: role,
      })
      setInvited(true)
      toast.success(`تم إرسال الدعوة إلى ${selectedUser.name}`)
    } catch (error) {
      console.error("Invite failed:", error)
      toast.error("فشل في إرسال الدعوة")
    } finally {
      setInviting(false)
    }
  }

  if (invited) {
    return (
      <div className="space-y-4 py-8 text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
          <Check className="h-6 w-6 text-green-600 dark:text-green-400" />
        </div>
        <p className="text-lg font-medium">تم إرسال الدعوة بنجاح</p>
        <Button onClick={onBack} variant="outline" className="gap-2">
          <ArrowRight className="h-4 w-4" />
          العودة للقائمة
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-4 py-4">
      {!selectedUser ? (
        <>
          <div className="relative">
            <Search className="absolute top-3 right-3 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="ابحث بالاسم، البريد الإلكتروني، أو اسم المستخدم..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="pr-9"
            />
          </div>

          <div className="h-75 overflow-y-auto rounded-md border">
            {loading ? (
              <div className="space-y-3 p-2">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="flex items-center gap-3 p-2">
                    <Skeleton className="h-10 w-10 rounded-full" />
                    <div className="space-y-2">
                      <Skeleton className="h-4 w-32" />
                      <Skeleton className="h-3 w-48" />
                    </div>
                  </div>
                ))}
              </div>
            ) : results.length > 0 ? (
              <div className="space-y-1 p-2">
                {results.map((user) => (
                  <div
                    key={user.id}
                    onClick={() => setSelectedUser(user)}
                    className="flex cursor-pointer items-center gap-3 rounded-lg p-2 transition-colors hover:bg-muted"
                  >
                    <Avatar className="h-10 w-10">
                      <AvatarImage src={user.picture} alt={user.name} />
                      <AvatarFallback>
                        {user.name?.charAt(0) || "?"}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-medium">{user.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {user.email}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : query.length >= 2 ? (
              <div className="p-2 py-8 text-center text-muted-foreground">
                لا توجد نتائج للبحث
              </div>
            ) : null}
          </div>
        </>
      ) : (
        <div className="space-y-6">
          <div className="flex items-center gap-4 rounded-lg bg-muted p-4">
            <Avatar className="h-16 w-16">
              <AvatarImage src={selectedUser.picture} alt={selectedUser.name} />
              <AvatarFallback>
                {selectedUser.name?.charAt(0) || "?"}
              </AvatarFallback>
            </Avatar>
            <div>
              <h3 className="text-lg font-semibold">{selectedUser.name}</h3>
              <p className="text-sm text-muted-foreground">
                {selectedUser.email}
              </p>
            </div>
          </div>

          <div className="flex gap-2">
            <Button
              onClick={() => setSelectedUser(null)}
              variant="outline"
              className="gap-2"
            >
              <ArrowRight className="h-4 w-4" />
              تراجع
            </Button>
            <Button
              onClick={handleInvite}
              disabled={inviting}
              className="flex-1 gap-2"
            >
              {inviting ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <UserPlus className="h-4 w-4" />
              )}
              {inviting ? "جاري الإرسال..." : "إرسال الدعوة"}
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}

// Public Invite Form with dark mode support
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
      setInviteLink(`${window.location.origin}/invite/${result.id}`)
      toast.success("تم إنشاء رابط الدعوة العامة")
    } catch (error) {
      console.error("Failed to create public invite:", error)
      toast.error("فشل في إنشاء الدعوة العامة")
    } finally {
      setInviting(false)
    }
  }

  return (
    <div className="space-y-6 py-4">
      {!inviteLink ? (
        <>
          <div className="space-y-2">
            <Label htmlFor="maxUses">الحد الأقصى للاستخدام</Label>
            <Input
              id="maxUses"
              type="number"
              min={1}
              max={100}
              value={maxUses}
              onChange={(e) => setMaxUses(parseInt(e.target.value) || 1)}
            />
            <p className="text-sm text-muted-foreground">
              عدد المرات التي يمكن فيها استخدام هذا الرابط
            </p>
          </div>

          <div className="flex gap-2">
            <Button
              onClick={handleCreatePublicInvite}
              disabled={inviting}
              className="flex-1 gap-2"
            >
              {inviting ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Users className="h-4 w-4" />
              )}
              {inviting ? "جاري الإنشاء..." : "إنشاء رابط الدعوة"}
            </Button>
          </div>
        </>
      ) : (
        <div className="space-y-4">
          <div className="rounded-lg border bg-card p-4 text-card-foreground">
            <div className="mb-3 flex items-center gap-2">
              <Check className="h-5 w-5 text-green-600 dark:text-green-400" />
              <p className="font-medium">تم إنشاء رابط الدعوة بنجاح</p>
            </div>
            <div className="flex gap-2">
              <Input
                value={inviteLink}
                readOnly
                className="bg-muted font-mono text-sm"
              />
              <Button
                onClick={() => {
                  navigator.clipboard.writeText(inviteLink)
                  toast.success("تم نسخ الرابط")
                }}
                variant="outline"
                size="icon"
              >
                <Copy className="h-4 w-4" />
              </Button>
            </div>
          </div>
          <Button onClick={onBack} variant="outline" className="w-full gap-2">
            <ArrowRight className="h-4 w-4" />
            العودة للقائمة
          </Button>
        </div>
      )}
    </div>
  )
}
