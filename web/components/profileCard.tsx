"use client"

import React, { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Building2, CheckCircle2, Upload } from "lucide-react"
import Image from "next/image"
import { updateOrganizationAction } from "@/lib/actions/organization"

interface ProfileCardProps {
  initialData: {
    name?: string
    description?: string
    image?: string
    visibility?: string
    slug?: string
  }
}

export function ProfileCard({ initialData }: ProfileCardProps) {
  const [name, setName] = useState(initialData.name || "")
  const [description, setDescription] = useState(initialData.description || "")
  const [loading, setLoading] = useState(false)

  const [selectedFile, setSelectedFile] = useState<File | null>(null)

  const handleLogoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setSelectedFile(file)
  }

  const handleSubmit = async (e: React.SubmitEvent) => {
    e.preventDefault()

    if (!initialData.slug) {
      console.error("Missing organization slug!")
      return
    }

    setLoading(true)

    try {
      const formData = new FormData()
      formData.append("oldSlug", initialData.slug)
      formData.append("name", name)
      formData.append("description", description)

      if (selectedFile) {
        formData.append("image", selectedFile)
      }

      const result = await updateOrganizationAction(formData)

      if (result.success) {
        console.log("Profile updated successfully!")
        setSelectedFile(null)
      } else {
        console.error("Update failed:", result.error)
      }
    } catch (error) {
      console.error(error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="h-full border-border bg-card shadow-sm" dir="rtl">
      <CardHeader className="flex flex-row items-center gap-2 border-b border-border py-2.5">
        <Building2 className="h-4 w-4 text-muted-foreground" />
        <CardTitle className="text-sm font-bold text-foreground">
          الملف الشخصي للمؤسسة
        </CardTitle>
      </CardHeader>

      <CardContent className="space-y-3 pt-3">
        <div className="flex items-center gap-3">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-lg border-2 border-dashed border-border bg-muted text-muted-foreground">
            {selectedFile ? (
              <Image
                width={56}
                height={56}
                src={URL.createObjectURL(selectedFile)}
                alt="Preview"
                className="h-full w-full object-cover"
              />
            ) : initialData.image ? (
              <Image
                width={56}
                height={56}
                src={initialData.image}
                alt="Logo"
                className="h-full w-full object-cover"
              />
            ) : (
              <Upload className="h-4 w-4" />
            )}
          </div>
          <div className="space-y-1">
            <h4 className="text-xs font-semibold text-foreground">
              شعار المؤسسة
            </h4>
            <label className="inline-block">
              <input
                type="file"
                accept="image/png, image/jpeg"
                className="hidden"
                onChange={handleLogoChange}
              />
              <span className="inline-flex cursor-pointer items-center justify-center gap-1 rounded-lg bg-primary px-2.5 py-1 text-[10px] font-medium text-primary-foreground transition-colors hover:bg-primary/90">
                {selectedFile ? <CheckCircle2 className="h-3 w-3" /> : null}
                {selectedFile ? "تم اختيار الصورة" : "رفع صورة جديدة"}
              </span>
            </label>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-2.5">
          <div className="space-y-1">
            <Label
              htmlFor="org-name"
              className="text-[10px] font-medium text-foreground"
            >
              اسم المؤسسة
            </Label>
            <Input
              id="org-name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="h-8 text-right text-xs focus-visible:ring-ring"
              disabled={loading}
            />
          </div>

          <div className="space-y-1">
            <Label
              htmlFor="org-desc"
              className="text-[10px] font-medium text-foreground"
            >
              الوصف
            </Label>
            <Textarea
              id="org-desc"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="min-h-15 text-right text-xs focus-visible:ring-ring"
              disabled={loading}
              rows={2}
            />
          </div>

          <Button
            type="submit"
            disabled={loading}
            className="h-8 cursor-pointer bg-primary px-3 py-1 text-xs text-primary-foreground hover:bg-primary/90"
          >
            {loading ? "جاري الحفظ..." : "حفظ التغييرات"}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}
