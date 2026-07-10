import { PlusIcon } from "lucide-react"
import Link from "next/link"

import { OrgCard } from "@/components/cards/org-card"
import { api } from "@/lib/api"

export async function OrgsGrid() {
  const organizations = await api.organizations.list()

  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4 *:aspect-video *:min-h-0 *:w-full">
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
  )
}
