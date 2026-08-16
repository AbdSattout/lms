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
        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowOwnerDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
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

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setSelectedType("admins")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
              المشرفين
            </CardTitle>
            <Users className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{adminCount}</div>
          </CardContent>
        </Card>

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setSelectedType("students")}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
              الطلاب
            </CardTitle>
            <Users className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{studentCount}</div>
          </CardContent>
        </Card>

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-destructive/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowBannedDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
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

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => setShowCoursesDialog(true)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
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

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => router.push(`/${slug}/posts` as Route)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
              المنشورات
            </CardTitle>
            <FileText className="h-5 w-5 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{overviewData.postsCount}</div>
          </CardContent>
        </Card>

        <Card
          className="cursor-pointer transition-all duration-200 hover:border-primary/50 hover:shadow-lg active:scale-[0.98]"
          onClick={() => router.push(`/${slug}/roadmaps` as Route)}
        >
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xl font-semibold text-foreground">
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

        {isOwner && (
          <Card
            className={
              isPremium
                ? "group relative overflow-hidden border border-amber-500/20 bg-gradient-to-br from-amber-500/[0.04] to-transparent transition-all duration-300 hover:shadow-lg dark:from-amber-500/10 dark:hover:shadow-[0_0_20px_rgba(245,158,11,0.08)]"
                : "opacity-85 transition-opacity duration-200 hover:opacity-100"
            }
          >
            {isPremium && (
              <>
                <div className="absolute inset-x-0 -top-px h-[1.5px] bg-gradient-to-r from-transparent via-amber-400/50 to-transparent" />
                <div className="pointer-events-none absolute top-0 left-0 h-16 w-16 bg-[radial-gradient(circle_at_top_left,_var(--tw-gradient-stops))] from-amber-500/30 to-transparent opacity-30 blur-md" />
              </>
            )}

            <CardHeader className="relative flex flex-row items-center justify-between space-y-0 pb-3">
              <CardTitle className="text-xl font-semibold text-foreground">
                التخزين
              </CardTitle>
              <div
                className={`flex items-center justify-center rounded-lg p-1.5 transition-colors ${isPremium ? "bg-amber-500/10 text-amber-500" : "bg-muted text-muted-foreground"}`}
              >
                <HardDrive className="h-4 w-4" />
              </div>
            </CardHeader>
            <CardContent className="relative">
              {isPremium ? (
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <Infinity className="h-6 w-6 stroke-[2.5px] text-amber-500 drop-shadow-[0_0_8px_rgba(245,158,11,0.4)]" />
                    <span className="bg-gradient-to-b from-amber-600 to-amber-500 bg-clip-text text-lg font-bold tracking-tight text-transparent dark:from-amber-300 dark:to-amber-500">
                      مساحة غير محدودة
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5 border-t border-amber-500/10 pt-2 text-xs text-muted-foreground">
                    <Crown className="h-3 w-3 text-amber-500/80" />
                    <p>
                      المستخدم:{" "}
                      <span className="font-medium text-foreground">
                        {formatBytes(overviewData.storage.usedBytes)}
                      </span>
                    </p>
                  </div>
                </div>
              ) : (
                <div className="space-y-2">
                  <div className="text-lg font-bold text-foreground">
                    {formatBytes(overviewData.storage.usedBytes)}
                  </div>
                  <p className="text-xs text-muted-foreground">
                    من {formatBytes(overviewData.storage.totalBytes ?? 0)}
                  </p>
                  <div className="h-2 w-full overflow-hidden rounded-full bg-muted/80">
                    <div
                      className="h-full rounded-full bg-primary transition-all duration-500"
                      style={{
                        width: `${Math.min(overviewData.storage.usagePercentage ?? 0, 100)}%`,
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
