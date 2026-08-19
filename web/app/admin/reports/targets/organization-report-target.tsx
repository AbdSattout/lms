"use client"

import { useEffect, useState, useTransition } from "react"
import { Building2, BookOpen, Users, FileText } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"

import type {
  CourseResponse,
  OrganizationResponse,
  PostResponse,
} from "@/lib/api/types"

import {
  getAdminOrganizationAction,
  getAdminOrganizationCoursesAction,
  getAdminOrganizationPostsAction,
} from "@/lib/actions/admin"
import { toast } from "sonner"

interface OrganizationTargetData {
  organization: OrganizationResponse
  courses: {
    content: CourseResponse[]
    totalElements: number
    totalPages: number
  }
  posts: {
    content: PostResponse[]
    totalElements: number
    totalPages: number
  }
}

export function OrganizationReportTarget({
  organizationId,
}: {
  organizationId: number
}) {
  const [data, setData] = useState<OrganizationTargetData | null>(null)
  const [isLoading, startLoading] = useTransition()

  useEffect(() => {
    startLoading(async () => {
      try {
        const [organization, courses, posts] = await Promise.all([
          getAdminOrganizationAction(organizationId),

          getAdminOrganizationCoursesAction(organizationId, {
            page: 0,
            size: 6,
            sort: ["createdAt,desc"],
          }),

          getAdminOrganizationPostsAction(organizationId, {
            page: 0,
            size: 6,
            sort: ["createdAt,desc"],
          }),
        ])

        setData({
          organization,
          courses,
          posts,
        })
      } catch (error) {
        toast.error("فشل تحميل المنظمة")
      }
    })
  }, [organizationId])
  if (isLoading && !data) {
    return <OrganizationTargetSkeleton />
  }

  if (!data) return null

  const { organization, courses, posts } = data

  const initials =
    organization.name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2) || "OR"

  return (
    <div className="space-y-4">
      <Card className="overflow-hidden border-border/60 shadow-sm">
        <CardContent className="p-6">
          <div className="flex items-start gap-4">
            <Avatar className="h-14 w-14 rounded-xl border border-border/50">
              <AvatarImage src={organization.image} />
              <AvatarFallback className="rounded-xl bg-primary/10 font-bold text-primary">
                {initials}
              </AvatarFallback>
            </Avatar>

            <div className="min-w-0 flex-1">
              <div className="flex flex-wrap items-center gap-2">
                <h3 className="text-xl font-bold">{organization.name}</h3>

                <Badge variant="secondary">{organization.visibility}</Badge>
              </div>

              <p className="mt-1 text-sm text-muted-foreground">
                @{organization.slug}
              </p>

              {organization.description && (
                <p className="mt-4 text-sm leading-6 text-muted-foreground">
                  {organization.description}
                </p>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-3 sm:grid-cols-3">
        <StatCard
          icon={Users}
          label="الأعضاء"
          value={organization.membersCount}
        />

        <StatCard
          icon={BookOpen}
          label="الدورات"
          value={organization.coursesCount}
        />

        <StatCard
          icon={Building2}
          label="المالك"
          value={organization.ownerName}
        />
      </div>

      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">الدورات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {courses.content.length === 0 ? (
            <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
              لا توجد دورات
            </div>
          ) : (
            courses.content.map((course) => (
              <div
                key={course.id}
                className="flex items-center gap-3 rounded-lg border border-border/50 p-3"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-muted">
                  <BookOpen className="h-4 w-4 text-muted-foreground" />
                </div>

                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold">
                    {course.title}
                  </p>

                  <p className="mt-0.5 truncate text-xs text-muted-foreground">
                    {course.slug}
                  </p>
                </div>

                <Badge variant="outline">{course.status}</Badge>
              </div>
            ))
          )}
        </CardContent>
      </Card>
      <Card className="border-border/60 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base">أحدث المنشورات</CardTitle>
        </CardHeader>

        <CardContent className="space-y-2">
          {posts.content.length === 0 ? (
            <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
              لا توجد منشورات
            </div>
          ) : (
            posts.content.map((post) => (
              <div
                key={post.id}
                className="flex items-center gap-3 rounded-lg border border-border/50 p-3"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-muted">
                  <FileText className="h-4 w-4 text-muted-foreground" />
                </div>

                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold">{post.title}</p>

                  <p className="mt-0.5 truncate text-xs text-muted-foreground">
                    {post.author?.name ?? "مستخدم مجهول"}
                  </p>
                </div>

                <span className="shrink-0 text-xs text-muted-foreground">
                  #{post.id}
                </span>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function StatCard({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof Users
  label: string
  value: string | number
}) {
  return (
    <Card className="border-border/60 shadow-sm">
      <CardContent className="p-4">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-muted">
            <Icon className="h-4 w-4 text-muted-foreground" />
          </div>

          <div className="min-w-0">
            <p className="text-xs text-muted-foreground">{label}</p>
            <p className="mt-0.5 truncate text-sm font-bold">{value}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

function OrganizationTargetSkeleton() {
  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="p-6">
          <div className="flex gap-4">
            <Skeleton className="h-14 w-14 rounded-xl" />

            <div className="flex-1 space-y-2">
              <Skeleton className="h-6 w-48" />
              <Skeleton className="h-4 w-32" />
              <Skeleton className="h-12 w-full" />
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-3 sm:grid-cols-3">
        {Array.from({ length: 3 }).map((_, index) => (
          <Skeleton key={index} className="h-20 rounded-xl" />
        ))}
      </div>

      <Skeleton className="h-64 rounded-xl" />
    </div>
  )
}
