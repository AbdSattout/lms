"use client"

import { useState, useTransition } from "react"
import { Loader2 } from "lucide-react"
import { toast } from "sonner"

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"

import { createAdminModeratorAction } from "@/lib/actions/admin-moderators"
import type { AdminResponse } from "@/lib/api/types"

interface CreateModeratorDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onCreated: (moderator: AdminResponse) => void
}

export function CreateModeratorDialog({
  open,
  onOpenChange,
  onCreated,
}: CreateModeratorDialogProps) {
  const [name, setName] = useState("")
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [isSubmitting, startSubmitting] = useTransition()

  const isEmailValid = /\S+@\S+\.\S+/.test(email)

  function reset() {
    setName("")
    setEmail("")
    setPassword("")
  }

  function handleOpenChange(nextOpen: boolean) {
    if (!nextOpen && !isSubmitting) {
      reset()
    }

    onOpenChange(nextOpen)
  }

  function handleSubmit() {
    if (!name.trim() || !isEmailValid || !password || isSubmitting) {
      return
    }

    startSubmitting(async () => {
      try {
        const moderator = await createAdminModeratorAction({
          name: name.trim(),
          email: email.trim(),
          password,
        })

        toast.success("تم إنشاء المشرف بنجاح")

        onCreated(moderator)
        reset()
        onOpenChange(false)
      } catch (error) {
        let errorMessage = "فشل إنشاء المشرف، يرجى المحاولة لاحقاً."

        if (error instanceof Error) {
          try {
            const jsonMatch = error.message.match(/\{.*\}/)

            if (jsonMatch) {
              const parsedError = JSON.parse(jsonMatch[0])

              if (
                parsedError.status === 409 ||
                parsedError.error === "Admin email already exists"
              ) {
                errorMessage = "البريد الإلكتروني مسجل مسبقاً لمشرف آخر."
              } else if (
                parsedError.status === 400 &&
                parsedError.errors?.email
              ) {
                errorMessage = "صيغة البريد الإلكتروني غير صالحة."
              }
            }
          } catch (e) {
            console.error("Failed to parse error message:", e)
          }
        }

        toast.error(errorMessage)
      }
    })
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent dir="rtl" className="sm:max-w-[480px]">
        <DialogHeader>
          <DialogTitle>إضافة مشرف</DialogTitle>

          <DialogDescription>
            إنشاء حساب مشرف جديد للوصول إلى لوحة الإدارة.
          </DialogDescription>
        </DialogHeader>

        <FieldGroup>
          <Field>
            <FieldLabel htmlFor="moderator-name">الاسم</FieldLabel>

            <Input
              id="moderator-name"
              value={name}
              onChange={(event) => setName(event.target.value)}
              placeholder="اسم المشرف"
              autoComplete="name"
            />
          </Field>

          <Field data-invalid={email.length > 0 && !isEmailValid}>
            <FieldLabel htmlFor="moderator-email">البريد الإلكتروني</FieldLabel>

            <Input
              id="moderator-email"
              type="email"
              dir="ltr"
              className="text-left"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="moderator@example.com"
              autoComplete="email"
            />

            <FieldDescription>
              يجب أن يكون البريد الإلكتروني صالحاً.
            </FieldDescription>

            {email.length > 0 && !isEmailValid && (
              <FieldError>البريد الإلكتروني غير صالح.</FieldError>
            )}
          </Field>

          <Field>
            <FieldLabel htmlFor="moderator-password">كلمة المرور</FieldLabel>

            <Input
              id="moderator-password"
              type="password"
              dir="ltr"
              className="text-left"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="••••••••"
              autoComplete="new-password"
            />
          </Field>
        </FieldGroup>

        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            disabled={isSubmitting}
            onClick={() => handleOpenChange(false)}
          >
            إلغاء
          </Button>

          <Button
            type="button"
            disabled={
              isSubmitting || !name.trim() || !isEmailValid || !password
            }
            onClick={handleSubmit}
          >
            {isSubmitting && <Loader2 className="ml-2 h-4 w-4 animate-spin" />}

            {isSubmitting ? "جاري الإنشاء..." : "إنشاء المشرف"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
