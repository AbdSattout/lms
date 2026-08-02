// components/owner-dialog.tsx
"use client"

import Image from "next/image"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import type { UserResponse } from "@/lib/api/types"
import { Shield, User, AtSign, Mail, Phone } from "lucide-react"
export type OwnerResponse = UserResponse & {
  memberId?: number
  role?: string
  user?: UserResponse
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
                  <p
                    className="font-medium text-foreground"
                    dir={owner.username ? "ltr" : "rtl"}
                  >
                    {owner.username || "غير متوفر"}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm">
                <Mail className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">
                    البريد الإلكتروني
                  </p>
                  <p
                    className={`font-medium text-foreground ${owner.email ? "ltr" : ""}`}
                    dir={owner.email ? "ltr" : "rtl"}
                  >
                    {owner.email || "غير متوفر"}
                  </p>
                </div>
              </div>

              {/* Phone Number */}
              <div className="flex items-center gap-3 text-sm">
                <Phone className="h-4 w-4 shrink-0 text-muted-foreground" />
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">رقم الهاتف</p>
                  <p
                    className={`font-medium text-foreground ${owner.phoneNumber ? "ltr" : ""}`}
                    dir={owner.phoneNumber ? "ltr" : "rtl"}
                  >
                    {owner.phoneNumber || "غير متوفر"}
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
