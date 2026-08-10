"use client"

import Link from "next/link"
import { FileQuestion } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

export default function VerifyNotFound() {
  return (
    <div
      dir="rtl"
      className="flex min-h-dvh items-center justify-center bg-muted/30 p-4"
    >
      <Card className="w-full max-w-md">
        <CardHeader className="justify-items-center items-center text-center">
          <div className="mb-2 flex size-12 items-center justify-center rounded-full bg-destructive/10">
            <FileQuestion className="size-6 text-destructive" />
          </div>
          <CardTitle className="text-xl">الشهادة غير موجودة</CardTitle>
          <CardDescription>
            لم يتم العثور على شهادة بهذا الرقم. تأكد من صحة الرابط أو راسل
            الجهة المانحة.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex justify-center">
          <Button
            render={(props) => <Link href="/verify" {...props} />}
            nativeButton={false}
            variant="outline"
          >
            العودة إلى التحقق
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
