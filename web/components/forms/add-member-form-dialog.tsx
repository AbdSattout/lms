"use client"

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { UserPlus, Users, Clock } from "lucide-react"
import { Role } from "@/lib/api/types"
import { SpecificInviteForm } from "./specific-invite-form"
import { PublicInviteForm } from "./public-invite-form"
import { PendingInvitesList } from "./pending-invite-form"

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

        {role !== "ADMIN" && (
          <TabsTrigger value="public" className="gap-2 py-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">دعوة عامة</span>
            <span className="sm:hidden">عامة</span>
          </TabsTrigger>
        )}

        <TabsTrigger value="pending" className="gap-2 py-2">
          <Clock className="h-4 w-4" />
          <span className="hidden sm:inline">سجل الدعوات</span>
          <span className="sm:hidden">دعوات</span>
        </TabsTrigger>
      </TabsList>

      <div className="mt-4 flex flex-1 flex-col overflow-hidden rounded-md border shadow-sm">
        <TabsContent
          value="specific"
          className="m-0 flex flex-1 flex-col overflow-hidden focus-visible:outline-none"
        >
          <SpecificInviteForm slug={slug} role={role} onBack={onBack} />
        </TabsContent>

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
