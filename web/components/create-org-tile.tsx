import { OrganizationDialog } from "@/components/forms/organization-dialog"
import { PlusIcon } from "lucide-react"

export function CreateOrgTile() {
  return (
    <OrganizationDialog>
      <button className="flex size-full cursor-pointer flex-col items-center justify-center rounded-4xl border-2 border-dashed border-border p-8 text-center transition hover:bg-muted/50">
        <div className="mb-4 rounded-full bg-primary/10 p-4 text-2xl text-primary">
          <PlusIcon className="size-6" />
        </div>
        <h3 className="font-bold">إنشاء أو انضمام</h3>
        <p className="text-sm text-muted-foreground">
          قم بإضافة مؤسسة جديدة لإدارة محتواك التعليمي
        </p>
      </button>
    </OrganizationDialog>
  )
}
