"use client"

import { CreateOrganizationDialog } from "@/components/forms/create-organization-dialog"
import { PlusIcon } from "lucide-react"
import { useState } from "react"

export function CreateOrgTile() {
  const [open, setOpen] = useState(false)

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="flex cursor-pointer flex-col items-center justify-center rounded-4xl border-2 border-dashed border-border p-8 text-center transition hover:bg-muted/50"
      >
        <div className="mb-4 rounded-full bg-primary/10 p-4 text-2xl text-primary">
          <PlusIcon className="size-6" />
        </div>
        <h3 className="font-bold">إنشاء أو انضمام</h3>
        <p className="text-sm text-muted-foreground">
          قم بإضافة مؤسسة جديدة لإدارة محتواك التعليمي
        </p>
      </button>
      <CreateOrganizationDialog open={open} onOpenChange={setOpen} />
    </>
  )
}
