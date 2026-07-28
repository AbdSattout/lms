import { api } from "@/lib/api"
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { notFound } from "next/navigation"
import { OrgMediaClient } from "./media-client"

export default async function OrgMediaPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params

  const org = await api.dashboard.organizations
    .bySlug.get(slug)
    .catch(() => null)

  if (!org) notFound()

  return (
    <>
      <BreadcrumbTrail items={[{ label: "مكتبة الوسائط" }]} />
      <OrgMediaClient slug={slug} organizationId={org.id} />
    </>
  )
}
