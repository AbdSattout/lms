import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { OrgMediaClient } from "./media-client"

export default async function OrgMediaPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params

  return (
    <>
      <BreadcrumbTrail items={[{ label: "مكتبة الوسائط" }]} />
      <OrgMediaClient slug={slug} />
    </>
  )
}
