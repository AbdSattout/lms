"use client"

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { OrganizationForm } from "@/components/forms/organization-form"
import type { ReactNode } from "react"
import { useState } from "react"

export function OrganizationDialog({ children }: { children?: ReactNode }) {
  const [open, setOpen] = useState(false)

  return (
    <>
      <div onClick={() => setOpen(true)}>{children}</div>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>إعداد منظمة جديدة</DialogTitle>
            <DialogDescription>يرجى إدخال تفاصيل المنظمة.</DialogDescription>
          </DialogHeader>
          <OrganizationForm onSuccess={() => setOpen(false)} />
        </DialogContent>
      </Dialog>
    </>
  )
}
