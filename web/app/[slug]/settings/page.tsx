import DeleteOrgCard from "@/components/cards/delete-org-card"
import { ProfileCard } from "@/components/cards/profile-card"
import { api } from "@/lib/api"
import { notFound } from "next/navigation"

interface SettingsPageProps {
  params: Promise<{
    slug: string
  }>
}

export default async function SettingsPage({ params }: SettingsPageProps) {
  await new Promise((resolve) => setTimeout(resolve, 10000))
  const { slug } = await params
  let organizationData
  try {
    organizationData = await api.dashboard.organizations.bySlug.get(slug)
    if (!organizationData) notFound()
  } catch {
    notFound()
  }

  return (
    <div className="flex h-full flex-col" dir="rtl">
      <header className="mb-8 shrink-0">
        <h1 className="text-center text-xl font-bold text-primary">
          إعدادات المؤسسة
        </h1>
        <h3 className="mt-0.5 text-center text-xs text-muted-foreground">
          قم بادارة ملف المؤسسة وإعداداتها
        </h3>
      </header>

      {/* Two columns - takes remaining height */}
      <div className="grid min-h-0 flex-1 grid-cols-1 gap-4 lg:grid-cols-2">
        {/* Profile Card */}
        <div className="overflow-y-auto">
          <ProfileCard initialData={organizationData} />
        </div>

        {/* Delete Card */}
        <div className="overflow-y-auto">
          <DeleteOrgCard slug={slug} />
        </div>
      </div>
    </div>
  )
}
