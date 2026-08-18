"use client"

import { useEffect, useState, useTransition } from "react"
import { Loader2, Plus, ShieldCheck } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

import { getAdminModeratorsAction } from "@/lib/actions/admin-moderators"

import type { AdminResponse } from "@/lib/api/types"
import { ModeratorList } from "@/components/admin/moderators-list"
import { CreateModeratorDialog } from "@/components/admin/create-moderator-dialog"

export function ModeratorsPage() {
  const [moderators, setModerators] = useState<AdminResponse[]>([])

  const [isLoading, startLoading] = useTransition()

  const [createOpen, setCreateOpen] = useState(false)

  useEffect(() => {
    loadModerators()
  }, [])

  function loadModerators() {
    startLoading(async () => {
      try {
        const result = await getAdminModeratorsAction({
          page: 0,
          size: 20,
          sort: ["id,desc"],
        })

        setModerators(result.content ?? [])
      } catch (error) {
        console.error("Failed to load moderators", error)
      }
    })
  }

  function handleCreated(moderator: AdminResponse) {
    setModerators((current) => [moderator, ...current])
  }

  function handleDeleted(moderatorId: number) {
    setModerators((current) =>
      current.filter((moderator) => moderator.id !== moderatorId)
    )
  }

  return (
    <>
      <div className="flex h-screen min-h-0 flex-col overflow-hidden">
        <header className="shrink-0 border-b bg-card">
          <div className="flex min-h-16 items-center justify-between gap-4 px-4 py-3 md:px-6">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <ShieldCheck className="h-5 w-5 text-primary" />
              </div>

              <div>
                <h1 className="font-bold">المشرفون</h1>

                <p className="text-xs text-muted-foreground">
                  إدارة مشرفي لوحة الإدارة
                </p>
              </div>
            </div>

            <Button onClick={() => setCreateOpen(true)}>
              <Plus className="ml-2 h-4 w-4" />
              إضافة مشرف
            </Button>
          </div>
        </header>

        <div className="min-h-0 flex-1 overflow-y-auto">
          <div className="mx-auto w-full max-w-4xl p-4 md:p-6 lg:p-8">
            <Card className="border-border/60 shadow-sm">
              <CardContent className="p-5 md:p-6">
                <div className="mb-5 flex items-center justify-between">
                  <div>
                    <h2 className="text-lg font-bold">المشرفون الحاليون</h2>

                    <p className="mt-1 text-sm text-muted-foreground">
                      الحسابات التي تمتلك صلاحية المشرف.
                    </p>
                  </div>

                  <div className="rounded-full bg-muted px-3 py-1 text-xs font-bold">
                    {moderators.length}
                  </div>
                </div>

                <Separator className="mb-5" />

                {isLoading ? (
                  <div className="flex items-center justify-center py-12">
                    <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
                  </div>
                ) : (
                  <ModeratorList
                    moderators={moderators}
                    onDeleted={handleDeleted}
                  />
                )}
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      <CreateModeratorDialog
        open={createOpen}
        onOpenChange={setCreateOpen}
        onCreated={handleCreated}
      />
    </>
  )
}
