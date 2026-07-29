"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, User, BookOpen, FileText, Map } from "lucide-react"
import { MembersDialog } from "../members-dialog"
import type { OrganizationOverviewResponse } from "@/lib/api/types"
import { Route } from "next"
import { CoursesOverviewDialog } from "../forms/course-overview-form"
import { OwnerDialog } from "../forms/owner-form-dialog"

interface OrgOverviewCardProps {
  slug: string
  overviewData: OrganizationOverviewResponse
  adminCount: number
  studentCount: number
}

export function OrgOverviewCard({
  slug,
  overviewData,
  adminCount,
  studentCount,
}: OrgOverviewCardProps) {
  const router = useRouter()
  const [selectedType, setSelectedType] = useState<
    "admins" | "students" | null
  >(null)
  const [showOwnerDialog, setShowOwnerDialog] = useState(false)
  const [showCoursesDialog, setShowCoursesDialog] = useState(false)

  return (
    <div className="w-full space-y-6">
      <div className="grid w-full grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        {/* Owner Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowOwnerDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              المالك
            </CardTitle>
            <User className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="truncate text-lg font-bold">
              {overviewData.owner.name}
            </div>
          </CardContent>
        </Card>

        {/* Admins Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
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

        {/* Students Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
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

        {/* Courses Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowCoursesDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              الدورات
            </CardTitle>
            <BookOpen className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {overviewData.coursesCount}
            </div>
            <p className="mt-1 text-xs text-muted-foreground">
              {overviewData.publishedCoursesCount} منشورة •{" "}
              {overviewData.draftCoursesCount} مسودة
            </p>
          </CardContent>
        </Card>

        {/* Posts Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => router.push(`/${slug}/posts` as Route)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              المنشورات
            </CardTitle>
            <FileText className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{overviewData.postsCount}</div>
          </CardContent>
        </Card>

        {/* Roadmaps Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => router.push(`/${slug}/roadmaps` as Route)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              المسارات
            </CardTitle>
            <Map className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {overviewData.roadmapsCount}
            </div>
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

      <OwnerDialog
        open={showOwnerDialog}
        onOpenChange={setShowOwnerDialog}
        owner={overviewData.owner}
      />

      <CoursesOverviewDialog
        open={showCoursesDialog}
        onOpenChange={setShowCoursesDialog}
        publishedCount={overviewData.publishedCoursesCount}
        draftCount={overviewData.draftCoursesCount}
      />
    </div>
  )
}
