// app/dashboard/[slug]/overview/page.tsx (Server Component)
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { OrgOverviewCard } from "@/components/cards/org-overview-card"
import { api } from "@/lib/api"

export default async function OverviewPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const [overviewData, adminsData, studentsData, currentuser] =
    await Promise.all([
      api.dashboard.organizations.overview.get(slug),
      api.dashboard.organizations.members.getAdmins(slug, { page: 0, size: 1 }),
      api.dashboard.organizations.members.getStudents(slug, {
        page: 0,
        size: 1,
      }),
      api.profile.me.get(),
    ])
  const ownerId = overviewData.owner.id
  console.log("overviewData", overviewData)
  return (
    <div className="flex flex-col gap-6" dir="rtl">
      <BreadcrumbTrail items={[{ label: "نظرة عامة" }]} />
      <h1 className="text-2xl font-bold">نظرة عامة</h1>

      <OrgOverviewCard
        slug={slug}
        overviewData={overviewData}
        adminCount={adminsData?.totalElements ?? 0}
        studentCount={studentsData?.totalElements ?? 0}
        isOwner={ownerId === currentuser.user.id}
      />
    </div>
  )
}
