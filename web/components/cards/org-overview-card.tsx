// components/cards/org-overview-card.tsx
"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Users } from "lucide-react"
import { MembersDialog } from "../members-dialog"

interface OrgOverviewCardProps {
  slug: string
  adminCount: number
  studentCount: number
}

export function OrgOverviewCard({
  slug,
  adminCount,
  studentCount,
}: OrgOverviewCardProps) {
  const [selectedType, setSelectedType] = useState<
    "admins" | "students" | null
  >(null)

  return (
    <>
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <Card
          className="cursor-pointer transition-shadow hover:shadow-lg"
          onClick={() => setSelectedType("admins")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">المشرفين</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{adminCount}</div>
          </CardContent>
        </Card>

        <Card
          className="cursor-pointer transition-shadow hover:shadow-lg"
          onClick={() => setSelectedType("students")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">الطلاب</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{studentCount}</div>
          </CardContent>
        </Card>
      </div>

      <MembersDialog
        open={selectedType !== null}
        onOpenChange={(open) => {
          if (!open) setSelectedType(null)
        }}
        type={selectedType}
        slug={slug}
      />
    </>
  )
}
