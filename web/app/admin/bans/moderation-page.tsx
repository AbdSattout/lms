"use client"

import { useEffect, useState, useTransition } from "react"
import {
  Ban,
  Building2,
  Loader2,
  Search,
  ShieldCheck,
  UserRound,
} from "lucide-react"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

import {
  getAdminOrganizationsAction,
  getAdminUsersAction,
  getBannedOrganizationsAction,
  getBannedUsersAction,
  unbanOrganizationAction,
  unbanUserAction,
} from "@/lib/actions/admin-moderation"

import type {
  BannedOrganizationResponse,
  BannedUserResponse,
  OrganizationResponse,
  UserResponse,
} from "@/lib/api/types"

import { BanDialog } from "./ban-dialog"
import { toast } from "sonner"

type ModerationTarget = "USERS" | "ORGANIZATIONS"

export function ModerationPage() {
  const [target, setTarget] = useState<ModerationTarget>("USERS")

  const [search, setSearch] = useState("")
  const [users, setUsers] = useState<UserResponse[]>([])
  const [organizations, setOrganizations] = useState<OrganizationResponse[]>([])

  const [bannedUsers, setBannedUsers] = useState<BannedUserResponse[]>([])

  const [bannedOrganizations, setBannedOrganizations] = useState<
    BannedOrganizationResponse[]
  >([])

  const [isSearching, startSearch] = useTransition()
  const [isLoadingBanned, startLoadBanned] = useTransition()

  const [banTarget, setBanTarget] = useState<
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
    | null
  >(null)

  async function loadBanned() {
    startLoadBanned(async () => {
      try {
        if (target === "USERS") {
          const result = await getBannedUsersAction({
            page: 0,
            size: 20,
            sort: ["baseEntity.createdAt,desc"],
          })

          setBannedUsers(result.content ?? [])
        } else {
          const result = await getBannedOrganizationsAction({
            page: 0,
            size: 20,
            sort: ["baseEntity.createdAt,desc"],
          })

          setBannedOrganizations(result.content ?? [])
        }
      } catch (error) {
        console.error("Failed to load banned entries", error)
      }
    })
  }

  function performSearch(value: string) {
    startSearch(async () => {
      try {
        if (!value.trim()) {
          setUsers([])
          setOrganizations([])
          return
        }

        if (target === "USERS") {
          const result = await getAdminUsersAction(value, {
            page: 0,
            size: 20,
            sort: ["name,asc"],
          })

          setUsers(result.content ?? [])
        } else {
          const result = await getAdminOrganizationsAction(value, {
            page: 0,
            size: 20,
            sort: ["name,asc"],
          })

          setOrganizations(result.content ?? [])
        }
      } catch (error) {
        console.error("Failed to search", error)
      }
    })
  }

  useEffect(() => {
    setSearch("")
    setUsers([])
    setOrganizations([])
    loadBanned()
  }, [target])

  return (
    <>
      <div className="flex h-screen min-h-0 flex-col overflow-hidden">
        <header className="shrink-0 border-b bg-card">
          <div className="flex min-h-16 items-center justify-between gap-4 px-4 py-3 md:px-6">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-destructive/10">
                <Ban className="h-5 w-5 text-destructive" />
              </div>

              <div>
                <h1 className="font-bold">الحظر</h1>

                <p className="text-xs text-muted-foreground">
                  إدارة حظر المستخدمين والمنظمات
                </p>
              </div>
            </div>
          </div>
        </header>

        <div className="min-h-0 flex-1 overflow-y-auto">
          <div className="mx-auto w-full max-w-7xl p-4 md:p-6 lg:p-8">
            <div className="mb-6 flex flex-wrap gap-2">
              <Button
                variant={target === "USERS" ? "default" : "outline"}
                onClick={() => setTarget("USERS")}
              >
                <UserRound className="ml-2 h-4 w-4" />
                المستخدمون
              </Button>

              <Button
                variant={target === "ORGANIZATIONS" ? "default" : "outline"}
                onClick={() => setTarget("ORGANIZATIONS")}
              >
                <Building2 className="ml-2 h-4 w-4" />
                المنظمات
              </Button>
            </div>

            <div className="grid gap-6 xl:grid-cols-[1fr_420px]">
              <Card className="border-border/60 shadow-sm">
                <CardHeader>
                  <CardTitle className="text-base">البحث</CardTitle>
                </CardHeader>

                <CardContent>
                  <div className="flex gap-2">
                    <div className="relative flex-1">
                      <Search className="pointer-events-none absolute top-1/2 right-3 h-4 w-4 -translate-y-1/2 text-muted-foreground" />

                      <Input
                        value={search}
                        onChange={(event) => setSearch(event.target.value)}
                        onKeyDown={(event) => {
                          if (event.key === "Enter") {
                            performSearch(search)
                          }
                        }}
                        placeholder={
                          target === "USERS"
                            ? "ابحث عن مستخدم..."
                            : "ابحث عن منظمة..."
                        }
                        className="pr-9"
                        dir="rtl"
                      />
                    </div>

                    <Button
                      onClick={() => performSearch(search)}
                      disabled={isSearching}
                    >
                      {isSearching && (
                        <Loader2 className="ml-2 h-4 w-4 animate-spin" />
                      )}
                      بحث
                    </Button>
                  </div>

                  <Separator className="my-5" />

                  {target === "USERS" ? (
                    <UserSearchResults
                      users={users}
                      onBan={(user) =>
                        setBanTarget({
                          type: "USER",
                          id: user.id,
                          name: user.name,
                        })
                      }
                    />
                  ) : (
                    <OrganizationSearchResults
                      organizations={organizations}
                      onBan={(organization) =>
                        setBanTarget({
                          type: "ORGANIZATION",
                          id: organization.id,
                          name: organization.name,
                        })
                      }
                    />
                  )}
                </CardContent>
              </Card>

              <BannedList
                target={target}
                users={bannedUsers}
                organizations={bannedOrganizations}
                loading={isLoadingBanned}
                onUnban={async (id) => {
                  if (target === "USERS") {
                    await unbanUserAction(id)

                    setBannedUsers((current) =>
                      current.filter((item) => item.user.id !== id)
                    )
                  } else {
                    await unbanOrganizationAction(id)

                    setBannedOrganizations((current) =>
                      current.filter((item) => item.organization.id !== id)
                    )
                  }
                }}
              />
            </div>
          </div>
        </div>
      </div>

      {banTarget && (
        <BanDialog
          open={!!banTarget}
          target={banTarget}
          onOpenChange={(open) => {
            if (!open) {
              setBanTarget(null)
            }
          }}
          onBanned={() => {
            setBanTarget(null)
            loadBanned()
          }}
        />
      )}
    </>
  )
}

function UserSearchResults({
  users,
  onBan,
}: {
  users: UserResponse[]
  onBan: (user: UserResponse) => void
}) {
  if (users.length === 0) {
    return <EmptySearch text="ابحث عن مستخدم لعرض النتائج." />
  }

  return (
    <div className="space-y-2">
      {users.map((user) => (
        <div
          key={user.id}
          className="flex items-center gap-3 rounded-lg border border-border/50 p-3"
        >
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
            {user.picture ? (
              <img
                src={user.picture}
                alt=""
                className="h-10 w-10 rounded-full object-cover"
              />
            ) : (
              <UserRound className="h-4 w-4 text-primary" />
            )}
          </div>

          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-semibold">{user.name}</p>

            <p className="truncate text-xs text-muted-foreground">
              @{user.username}
            </p>
          </div>

          <Button size="sm" variant="destructive" onClick={() => onBan(user)}>
            <Ban className="ml-1.5 h-3.5 w-3.5" />
            حظر
          </Button>
        </div>
      ))}
    </div>
  )
}

function OrganizationSearchResults({
  organizations,
  onBan,
}: {
  organizations: OrganizationResponse[]
  onBan: (organization: OrganizationResponse) => void
}) {
  if (organizations.length === 0) {
    return <EmptySearch text="ابحث عن منظمة لعرض النتائج." />
  }

  return (
    <div className="space-y-2">
      {organizations.map((organization) => (
        <div
          key={organization.id}
          className="flex items-center gap-3 rounded-lg border border-border/50 p-3"
        >
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
            {organization.image ? (
              <img
                src={organization.image}
                alt=""
                className="h-10 w-10 rounded-lg object-cover"
              />
            ) : (
              <Building2 className="h-4 w-4 text-primary" />
            )}
          </div>

          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-semibold">
              {organization.name}
            </p>

            <p className="truncate text-xs text-muted-foreground">
              @{organization.slug}
            </p>
          </div>

          <Button
            size="sm"
            variant="destructive"
            onClick={() => onBan(organization)}
          >
            <Ban className="ml-1.5 h-3.5 w-3.5" />
            حظر
          </Button>
        </div>
      ))}
    </div>
  )
}

function BannedList({
  target,
  users,
  organizations,
  loading,
  onUnban,
}: {
  target: ModerationTarget
  users: BannedUserResponse[]
  organizations: BannedOrganizationResponse[]
  loading: boolean
  onUnban: (id: number) => Promise<void>
}) {
  const [unbanningId, setUnbanningId] = useState<number | null>(null)

  async function handleUnban(id: number) {
    try {
      setUnbanningId(id)

      await onUnban(id)

      toast.success("تم إلغاء الحظر بنجاح")
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "فشل إلغاء الحظر")
    } finally {
      setUnbanningId(null)
    }
  }

  const items = target === "USERS" ? users : organizations

  return (
    <Card className="border-border/60 shadow-sm">
      <CardHeader>
        <div className="flex items-center justify-between gap-3">
          <CardTitle className="text-base">
            {target === "USERS" ? "المستخدمون المحظورون" : "المنظمات المحظورة"}
          </CardTitle>

          <Badge variant="secondary">{items.length}</Badge>
        </div>
      </CardHeader>

      <CardContent>
        {loading ? (
          <div className="flex items-center justify-center py-10">
            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        ) : items.length === 0 ? (
          <div className="rounded-lg border border-dashed p-8 text-center">
            <ShieldCheck className="mx-auto h-8 w-8 text-muted-foreground/50" />

            <p className="mt-3 text-sm font-semibold">لا توجد عناصر محظورة</p>
          </div>
        ) : target === "USERS" ? (
          <div className="space-y-2">
            {users.map((item) => (
              <div
                key={item.id}
                className="rounded-lg border border-border/50 p-3"
              >
                <div className="flex items-start gap-3">
                  <UserRound className="mt-1 h-4 w-4 text-muted-foreground" />

                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-semibold">{item.user.name}</p>

                    <p className="text-xs text-muted-foreground">
                      @{item.user.username}
                    </p>

                    <p className="mt-2 text-xs leading-5 text-muted-foreground">
                      {item.reason}
                    </p>

                    <p className="mt-2 text-xs font-medium">
                      {item.expiresAt
                        ? `ينتهي: ${new Date(item.expiresAt).toLocaleString(
                            "ar"
                          )}`
                        : "حظر دائم"}
                    </p>
                  </div>

                  <Button
                    size="sm"
                    variant="outline"
                    disabled={unbanningId === item.user.id}
                    onClick={() => handleUnban(item.user.id)}
                  >
                    {unbanningId === item.user.id ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      "إلغاء الحظر"
                    )}
                  </Button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-2">
            {organizations.map((item) => (
              <div
                key={item.id}
                className="rounded-lg border border-border/50 p-3"
              >
                <div className="flex items-start gap-3">
                  <Building2 className="mt-1 h-4 w-4 text-muted-foreground" />

                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-semibold">
                      {item.organization.name}
                    </p>

                    <p className="text-xs text-muted-foreground">
                      @{item.organization.slug}
                    </p>

                    <p className="mt-2 text-xs leading-5 text-muted-foreground">
                      {item.reason}
                    </p>

                    <p className="mt-2 text-xs font-medium">
                      {item.expiresAt
                        ? `ينتهي: ${new Date(item.expiresAt).toLocaleString(
                            "ar"
                          )}`
                        : "حظر دائم"}
                    </p>
                  </div>

                  <Button
                    size="sm"
                    variant="outline"
                    disabled={unbanningId === item.organization.id}
                    onClick={() => handleUnban(item.organization.id)}
                  >
                    {unbanningId === item.organization.id ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      "إلغاء الحظر"
                    )}
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

function EmptySearch({ text }: { text: string }) {
  return (
    <div className="rounded-lg border border-dashed p-10 text-center text-sm text-muted-foreground">
      {text}
    </div>
  )
}
