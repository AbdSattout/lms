import { OrgAvatar } from "@/components/org-avatar"
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
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
          <Link key={org.slug} href={`/${org.slug}`}>
            <Card className="h-full cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-xl">
              <CardHeader className="relative flex-row items-center gap-3 space-y-0">
                {org.visibility && (
                  <Badge variant="secondary" className="absolute inset-e-6 top-0">
                    {org.visibility === "PUBLIC" ? "عام" : "خاص"}
                  </Badge>
                )}
                <OrgAvatar src={org.image} name={org.name} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <CardTitle className="text-base">{org.name}</CardTitle>
                  </div>
                  {org.description && (
                    <CardDescription className="line-clamp-2 text-xs">
                      {org.description}
                    </CardDescription>
                  )}
                </div>
              </CardHeader>
              {org.ownerName && (
                <CardFooter className="mt-auto text-xs text-muted-foreground">
                  {org.ownerName}
                </CardFooter>
              )}
            </Card>
          </Link>
        ))}
      </div>
    </div>
  )
}
