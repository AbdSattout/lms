"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Users,
  User,
  BookOpen,
  FileText,
  Map,
  UserX,
  HardDrive,
  Crown,
  Infinity,
} from "lucide-react"
import { MembersDialog } from "../members-dialog"
import type { OrganizationOverviewResponse } from "@/lib/api/types"
import { Route } from "next"
import { CoursesOverviewDialog } from "../forms/course-overview-form"
import { OwnerDialog } from "../forms/owner-form-dialog"
import { formatBytes } from "@/lib/utils/format-bytes"
import { BannedUsersDialog } from "../forms/banned-users-dialog"

interface OrgOverviewCardProps {
  slug: string
  overviewData: OrganizationOverviewResponse
  adminCount: number
  studentCount: number
  isOwner: boolean
}

export function OrgOverviewCard({
  slug,
  overviewData,
  adminCount,
  studentCount,
  isOwner,
}: OrgOverviewCardProps) {
  const router = useRouter()
  const [selectedType, setSelectedType] = useState<
    "admins" | "students" | null
  >(null)
  const [showOwnerDialog, setShowOwnerDialog] = useState(false)
  const [showCoursesDialog, setShowCoursesDialog] = useState(false)
  const [showBannedDialog, setShowBannedDialog] = useState(false)

  const isPremium = overviewData.ownerPlan.premium ?? false

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

        {/* Banned Students Card */}
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-destructive/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowBannedDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-foreground">
              الطلاب المحظورين
            </CardTitle>
            <UserX className="h-5 w-5 text-destructive" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-destructive">
              {overviewData.bannedUsersCount}
            </div>
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

        {/* Storage Card - Only visible to owner */}
        {isOwner && (
          <Card
            className={`relative transition-all duration-200 ${
              isPremium
                ? "border-2 border-amber-400/50 bg-gradient-to-br from-amber-50/50 to-transparent shadow-lg shadow-amber-100/50"
                : "opacity-75"
            }`}
          >
            {isPremium && (
              <div className="absolute -top-2 left-1/2 -translate-x-1/2 transform">
                <div className="rounded-full bg-gradient-to-r from-amber-400 to-yellow-500 p-1 shadow-lg">
                  <Crown className="h-4 w-4 text-white" />
                </div>
              </div>
            )}
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-semibold text-foreground">
                التخزين
              </CardTitle>
              <HardDrive
                className={`h-5 w-5 ${isPremium ? "text-amber-500" : "text-muted-foreground"}`}
              />
            </CardHeader>
            <CardContent>
              {isPremium ? (
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <Infinity className="h-6 w-6 text-amber-500" />
                    <span className="text-lg font-bold text-foreground">
                      مساحة غير محدودة
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    مستخدم: {formatBytes(overviewData.storage.usedBytes)}
                  </p>
                </div>
              ) : (
                <div className="space-y-2">
                  <div className="text-lg font-bold text-foreground">
                    {formatBytes(overviewData.storage.usedBytes)}
                  </div>
                  <p className="text-xs text-muted-foreground">
                    من {formatBytes(overviewData.storage.totalBytes ?? 0)}
                  </p>
                  <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
                    <div
                      className="h-full rounded-full bg-primary transition-all"
                      style={{
                        width: `${overviewData.storage.usagePercentage ?? 0}%`,
                      }}
                    />
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>

      <MembersDialog
        open={selectedType !== null}
        onOpenChange={(open) => {
          if (!open) setSelectedType(null)
        }}
        type={selectedType}
        slug={slug}
        ownerId={overviewData.owner.id}
        isOwner={isOwner}
      />

      <BannedUsersDialog
        open={showBannedDialog}
        onOpenChange={setShowBannedDialog}
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
