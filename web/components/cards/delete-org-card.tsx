import { Card, CardContent } from "@/components/ui/card"

interface deleteOrgProps {
  slug: string
}

export default function DeleteOrgCard({ slug }: deleteOrgProps) {
  return (
    <Card>
      <CardContent>
        <p className="text-muted-foreground">
          حذف الحساب بشكل نهائي لا يمكن التراجع!
        </p>
      </CardContent>
    </Card>
  )
}
