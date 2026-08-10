// app/[slug]/settings/page.tsx
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { DeleteOrgButton } from "@/components/delete-org-button"
import { OrganizationForm } from "@/components/forms/organization-form"
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
  try {
    organizationData = await api.dashboard.organizations.bySlug.get(slug)
    if (!organizationData) notFound()
  } catch {
    notFound()
  }

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
        </section>

        <section className="flex flex-col gap-6">
          <div className="flex flex-col gap-4">
            <h2 className="text-lg font-semibold">مغادرة المنظمة</h2>
            <Card>
              <CardContent className="pt-6">
                <p className="text-muted-foreground">
                  بمغادرة المنظمة، ستفقد الوصول إلى جميع محتوياتها. يمكنك
                  الانضمام مجدداً في أي وقت من خلال رابط الدعوة أو طلب الانضمام
                  إذا كانت المنظمة عامة.
                </p>
              </CardContent>
              <CardFooter>
                <LeaveOrgButton slug={slug} />
              </CardFooter>
            </Card>
          </div>

          <div className="flex flex-col gap-4">
            <h2 className="text-lg font-semibold text-destructive">
              حذف المنظمة
            </h2>
            <Card className="border-destructive/30">
              <CardContent className="pt-6">
                <p className="text-muted-foreground">
                  سيؤدي حذف هذه المنظمة إلى حذف جميع بياناتها بما فيها الكورسات،
                  المنشورات، الملفات، والكويزات. هذا الإجراء لا يمكن التراجع
                  عنه.
                </p>
              </CardContent>
              <CardFooter>
                <DeleteOrgButton slug={slug} />
              </CardFooter>
            </Card>
          </div>
        </section>
      </div>
    </>
  )
}
