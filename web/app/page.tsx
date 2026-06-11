import { OrgCard } from "@/components/org-card"
import { api } from "@/lib/api"
import { PlusIcon } from "lucide-react"
import Link from "next/link"

export default async function HomePage() {
  const organizations = await api.organizations.list.get()

  return (
    <div className="p-8">
      <h1 className="mb-6 font-heading text-2xl">منظماتي</h1>

      <div className="grid grid-cols-2 gap-6 md:grid-cols-3 lg:grid-cols-4">
        <Link
          href="/new"
          className="flex flex-col items-center justify-center rounded-4xl border-2 border-dashed border-border p-8 text-center transition hover:bg-muted/50"
        >
          <div className="mb-4 rounded-full bg-primary/10 p-4 text-2xl text-primary">
            <PlusIcon className="size-6" />
          </div>
          <h3 className="font-bold">إنشاء أو انضمام</h3>
          <p className="text-sm text-muted-foreground">
            قم بإضافة مؤسسة جديدة لإدارة محتواك التعليمي
          </p>
        </Link>

        {organizations.map((org) => (
          <OrgCard key={org.slug} org={org} />
        ))}
      </div>
    </div>
  )
}
