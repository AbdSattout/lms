// components/owner-dialog.tsx
"use client"

import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { Shield, User, AtSign } from "lucide-react"
import type { UserResponse } from "@/lib/api/types"

export type OwnerResponse = UserResponse & {
  username?: string
}

interface OwnerDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  owner: OwnerResponse
}

export function OwnerDialog({ open, onOpenChange, owner }: OwnerDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogTitle className="sr-only">معلومات المالك</DialogTitle>

        <div className="flex flex-col items-center space-y-6 p-6">
          <div className="relative">
            <Image
              src={owner.picture || "/default-avatar.png"}
              alt={owner.name || "Owner"}
              width={100}
              height={100}
              className="rounded-full object-cover ring-4 ring-muted"
            />
            <div className="absolute -right-1 -bottom-1 rounded-full bg-primary p-1.5 text-primary-foreground">
              <Shield className="h-4 w-4" />
            </div>
          </div>

          <div className="w-full space-y-4">
            <div className="space-y-1 text-center">
              <h3 className="text-xl font-bold text-foreground">
                {owner.name}
              </h3>
            </div>

            <div className="space-y-3 rounded-lg bg-muted/50 p-4">
              <div className="flex items-center gap-3 text-sm">
                <User className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div>
                  <p className="text-xs text-muted-foreground">الاسم</p>
                  <p className="font-medium text-foreground">{owner.name}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <AtSign className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div>
                  <p className="text-xs text-muted-foreground">اسم المستخدم</p>
                  <p className="font-medium text-foreground" dir="ltr">
                    {owner.username ? `@${owner.username}` : "غير متوفر"}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
