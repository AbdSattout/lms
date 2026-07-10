import { CreateOrganizationForm } from "@/components/forms/create-organization-form"
import { Card, CardContent } from "@/components/ui/card"
import { ArrowRightIcon } from "lucide-react"
import Link from "next/link"

export default function NewOrganizationPage() {
  return (
    <div className="mx-auto max-w-4xl p-8">
      <div className="mb-8">
        <div className="mb-2 flex items-center gap-4">
          <Link
            href="/"
            className="text-muted-foreground hover:text-foreground"
          >
            <ArrowRightIcon className="size-4" />
            عودة
          </Link>
          <h1 className="text-2xl font-bold">إعداد منظمة جديدة</h1>
        </div>
        <p className="text-muted-foreground">يرجى إدخال تفاصيل المنظمة.</p>
      </div>
      <Card className="max-w-md">
        <CardContent>
          <CreateOrganizationForm />
        </CardContent>
      </Card>
    </div>
  )
}
