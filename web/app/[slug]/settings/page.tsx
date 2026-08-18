// app/[slug]/settings/page.tsx

import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { DeleteOrgButton } from "@/components/delete-org-button"
import { OrganizationForm } from "@/components/forms/organization-form"
import { OrganizationVerificationCard } from "@/components/organization-verification-card"
import { Card, CardContent, CardFooter } from "@/components/ui/card"
import { LeaveOrgButton } from "@/components/ui/leave-org-button"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"

interface SettingsPageProps {
  params: Promise<{ slug: string }>
}

export default async function SettingsPage({ params }: SettingsPageProps) {
  const { slug } = await params

  let organizationData
  let overviewData
  let currentUser

  try {
    ;[organizationData, overviewData, currentUser] = await Promise.all([
      api.dashboard.organizations.bySlug.get(slug),
      api.dashboard.organizations.overview.get(slug),
      api.profile.me.get(),
    ])

    if (!organizationData || !overviewData || !currentUser) {
      notFound()
    }
  } catch {
    notFound()
  }

  const isOwner = currentUser.user.id === overviewData.owner.id

  const isAdmin = currentUser.user.id !== overviewData.owner.id

  const verificationRequests = isOwner
    ? (
        await api.dashboard.organizations.verificationRequests.list
          .get(slug, {
            page: 0,
            size: 5,
            sort: ["createdAt,desc"],
          })
          .catch(() => ({ content: [] }))
      ).content ?? []
    : []

  return (
    <>
      <BreadcrumbTrail items={[{ label: "الإعدادات" }]} />
      <h1 className="mb-6 text-2xl font-bold">الإعدادات</h1>

      <div className="grid w-full grid-cols-1 items-start gap-6 lg:grid-cols-2">
        <section className="flex flex-col gap-4">
          <h2 className="text-lg font-semibold">معلومات المنظمة</h2>

          <Card>
            <CardContent>
              <OrganizationForm initialData={organizationData} />
            </CardContent>
          </Card>

          {isOwner && (
            <OrganizationVerificationCard
              organization={organizationData}
              requests={verificationRequests}
            />
          )}
        </section>

        <section className="flex flex-col gap-6">
          {isAdmin && !isOwner && (
            <div className="flex flex-col gap-4">
              <h2 className="text-lg font-semibold">مغادرة المنظمة</h2>

              <Card>
                <CardContent className="pt-6">
                  <p className="text-muted-foreground">
                    بمغادرة المنظمة، ستفقد الوصول إلى جميع محتوياتها. يمكنك
                    الانضمام مجدداً في أي وقت من خلال رابط الدعوة أو طلب
                    الانضمام إذا كانت المنظمة عامة.
                  </p>
                </CardContent>

                <CardFooter>
                  <LeaveOrgButton slug={slug} />
                </CardFooter>
              </Card>
            </div>
          )}

          {/* OWNER ONLY */}
          {isOwner && (
            <div className="flex flex-col gap-4">
              <h2 className="text-lg font-semibold text-destructive">
                حذف المنظمة
              </h2>

              <Card className="border-destructive/30">
                <CardContent className="pt-6">
                  <p className="text-muted-foreground">
                    سيؤدي حذف هذه المنظمة إلى حذف جميع بياناتها بما فيها
                    الكورسات، المنشورات، الملفات، والكويزات. هذا الإجراء لا يمكن
                    التراجع عنه.
                  </p>
                </CardContent>

                <CardFooter>
                  <DeleteOrgButton slug={slug} />
                </CardFooter>
              </Card>
            </div>
          )}
        </section>
      </div>
    </>
  )
}
