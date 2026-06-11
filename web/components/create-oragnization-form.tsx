"use client"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { checkSlugAvailability } from "@/lib/actions/check-slug-availability"
import { createOrganization } from "@/lib/actions/create-organization"
import { generateSlug } from "@/lib/utils"
import { CheckIcon, Loader2Icon, XIcon } from "lucide-react"
import { useActionState, useEffect, useRef, useState } from "react"

export function CreateOrganizationForm() {
  const [state, formAction, isPending] = useActionState(createOrganization, {
    error: "",
  })

  const [slug, setSlug] = useState("")
  const [slugStatus, setSlugStatus] = useState<
    "idle" | "checking" | "available" | "taken"
  >("idle")
  const slugTimer = useRef<ReturnType<typeof setTimeout>>(null)
  const lastCheckedSlug = useRef("")
  const userEditedSlug = useRef(false)

  useEffect(() => {
    return () => {
      if (slugTimer.current) clearTimeout(slugTimer.current)
    }
  }, [])

  function handleNameChange(value: string) {
    if (userEditedSlug.current) return
    const generated = generateSlug(value)
    if (generated !== null) setSlug(generated)
  }

  function handleSlugChange(value: string) {
    userEditedSlug.current = true
    const filtered = value.replace(/[^a-z-]/g, "")
    setSlug(filtered)
    if (!filtered) {
      userEditedSlug.current = false
      setSlugStatus("idle")
    }
  }

  useEffect(() => {
    if (slugTimer.current) clearTimeout(slugTimer.current)
    if (!slug) return

    slugTimer.current = setTimeout(async () => {
      if (slug === lastCheckedSlug.current) return
      setSlugStatus("checking")
      try {
        const available = await checkSlugAvailability(slug)
        lastCheckedSlug.current = slug
        setSlugStatus(available ? "available" : "taken")
      } catch {
        setSlugStatus("idle")
      }
    }, 500)
  }, [slug])

  return (
    <form action={formAction} className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="name">اسم المنظمة</Label>
        <Input
          id="name"
          name="name"
          required
          disabled={isPending}
          onChange={(e) => handleNameChange(e.target.value)}
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="slug" className="flex items-center gap-2">
          الرابط
        </Label>
        <div className="relative">
          <Input
            id="slug"
            name="slug"
            dir="ltr"
            value={slug}
            onChange={(e) => handleSlugChange(e.target.value)}
            placeholder="my-organization"
            disabled={isPending}
            className={slugStatus === "taken" ? "border-destructive" : ""}
          />
          <span className="absolute start-3 top-1/2 -translate-y-1/2 transform">
            {slugStatus === "checking" && (
              <Loader2Icon className="size-4 animate-spin text-muted-foreground" />
            )}
            {slugStatus === "available" && (
              <CheckIcon className="size-4 text-green-600" />
            )}
            {slugStatus === "taken" && (
              <XIcon className="size-4 text-destructive" />
            )}
          </span>
        </div>
        <p className="text-xs text-muted-foreground">
          أحرف إنجليزية صغيرة وشرطات فقط
        </p>
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="description">الوصف</Label>
        <Textarea
          id="description"
          name="description"
          required
          disabled={isPending}
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="image">شعار المنظمة</Label>
        <Input
          id="image"
          name="image"
          type="file"
          accept="image/*"
          disabled={isPending}
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="visibility">حالة الظهور</Label>
        <Select name="visibility" defaultValue="PUBLIC" disabled={isPending}>
          <SelectTrigger id="visibility" className="w-full!">
            <SelectValue placeholder="اختر">
              {(value: string | null) => {
                const labels: Record<string, string> = {
                  PUBLIC: "عام",
                  PRIVATE: "خاص",
                }
                return value ? labels[value] || value : null
              }}
            </SelectValue>
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectItem value="PUBLIC">عام</SelectItem>
              <SelectItem value="PRIVATE">خاص</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      </div>

      {state.error && <p className="text-sm text-destructive">{state.error}</p>}

      <Button type="submit" disabled={isPending} className="mt-2 w-full">
        {isPending ? "جاري الإنشاء..." : "إنشاء المنظمة"}
      </Button>
    </form>
  )
}
