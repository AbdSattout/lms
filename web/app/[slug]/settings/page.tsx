import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { DeleteOrgButton } from "@/components/delete-org-button"
import { OrganizationForm } from "@/components/forms/organization-form"
import { Card, CardContent, CardFooter } from "@/components/ui/card"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"
interface SettingsPageProps {
  params: Promise<{
    slug: string
  }>
}
export default async function SettingsPage({ params }: SettingsPageProps) {
  const { slug } = await params
  let organizationData
  try {
    organizationData = await api.dashboard.organizations.bySlug.get(slug)
    if (!organizationData) notFound()
  } catch {
    notFound()
  }
  return (
    <div className="flex flex-col gap-6" dir="rtl">
      <BreadcrumbTrail items={[{ label: "الإعدادات" }]} />
      <h1 className="text-2xl font-bold">الإعدادات</h1>

      <div className="grid w-full grid-cols-1 items-start gap-6 lg:grid-cols-2">
        <section className="flex flex-col gap-4">
          <h2 className="text-lg font-semibold">معلومات المنظمة</h2>
          <Card>
            <CardContent>
              <OrganizationForm initialData={organizationData} />
            </CardContent>
          </Card>
        </section>
        <section className="flex flex-col gap-4">
          <h2 className="text-lg font-semibold">حذف المنظمة</h2>
          <Card>
            <CardContent>
              <p>
                سيؤدي حذف هذه المنظمة إلى حذف جميع بياناتها بما فيها الكورسات،
                المنشورات، الملفات، والكويزات.
              </p>
            </CardContent>
            <CardFooter>
              <DeleteOrgButton slug={slug} />
            </CardFooter>
          </Card>
        </section>
      </div>
    </div>
  )
}
