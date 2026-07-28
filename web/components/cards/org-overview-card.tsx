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
    <div className="w-full space-y-6">
      {/* 
         الـ `xl:grid-cols-4` سيجعلها تتسع لـ 4 بطاقات بمجرد إضافتها في المستقبل، 
         وتم إلغاء تقييد العرض (max-w) ليملأ سطر العمل كاملًا بمرونة واحترافية!
      */}
      <div className="grid w-full grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        <Card
          className="cursor-pointer transition-shadow hover:shadow-lg active:scale-[0.98]"
          onClick={() => setSelectedType("admins")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              المشرفين
            </CardTitle>
            <Users className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{adminCount}</div>
          </CardContent>
        </Card>

        <Card
          className="cursor-pointer transition-shadow hover:shadow-lg active:scale-[0.98]"
          onClick={() => setSelectedType("students")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              الطلاب
            </CardTitle>
            <Users className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{studentCount}</div>
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
    </div>
  )
}
