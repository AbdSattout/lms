import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { TriangleAlert } from "lucide-react"
import { DeleteOrgButton } from "../delete-org-button"

interface deleteOrgProps {
  slug: string
}

export default function DeleteOrgCard({ slug }: deleteOrgProps) {
  return (
    <Card className="border-border bg-card shadow-sm" dir="rtl">
      <CardHeader className="flex flex-row items-center gap-2 border-b border-border py-3">
        <TriangleAlert className="h-5 w-5 text-destructive" />
        <CardTitle className="text-base font-bold text-destructive">
          حذف المؤسسه
        </CardTitle>
      </CardHeader>
      <CardContent className="pt-4">
        <p className="text-sm font-semibold text-muted-foreground">
          حذف الحساب بشكل نهائي لا يمكن التراجع!
        </p>
        <div className="mt-4">
          <DeleteOrgButton slug={slug} />
        </div>
      </CardContent>
    </Card>
  )
}
