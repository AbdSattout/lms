import type { Metadata } from "next"
import Link from "next/link"
import { notFound } from "next/navigation"
import { ArrowRight, Download, CheckCircle2 } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { getCertificate, isCertificateNotFound, SAFE_CODE_PATTERN } from "@/lib/certificate/data"
import { gradeLabels } from "@/lib/certificate/theme"
import type { CertificateResponse } from "@/lib/api/types"

export const metadata: Metadata = {
  title: "التحقق من الشهادة",
}

export default async function VerifyPage({
  params,
}: {
  params: Promise<{ code: string }>
}) {
  const { code } = await params

  if (!SAFE_CODE_PATTERN.test(code)) {
    notFound()
  }

  let cert: CertificateResponse | null = null
  try {
    cert = await getCertificate(code)
  } catch (err) {
    if (isCertificateNotFound(err)) {
      notFound()
    }
    console.error("Certificate lookup failed:", err)
  }

  if (!cert) {
    notFound()
  }

  const scanUrl = `/api/certificates/${encodeURIComponent(cert.certificateCode)}`

  return (
    <div
      dir="rtl"
      className="flex min-h-dvh items-center justify-center bg-muted/30 p-4"
    >
      <Card className="w-full max-w-lg">
        <CardHeader className="justify-items-center items-center text-center">
          <div className="mb-2 flex size-12 items-center justify-center rounded-full bg-primary/10">
            <CheckCircle2 className="size-6 text-primary" />
          </div>
          <CardTitle className="text-xl">شهادة صالحة</CardTitle>
          <CardDescription>
            تم التحقق من الشهادة بنجاح في منصة مسار
          </CardDescription>
        </CardHeader>

        <CardContent className="flex flex-col gap-4">
          <dl className="flex flex-col gap-3 rounded-4xl border bg-background p-4 text-sm">
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">اسم الطالب</dt>
              <dd className="font-semibold">{cert.studentName}</dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">الدورة</dt>
              <dd className="font-semibold">{cert.courseName}</dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">الجهة المانحة</dt>
              <dd className="font-semibold">{cert.organization.name}</dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">التقدير</dt>
              <dd>
                <Badge>{gradeLabels[cert.grade]}</Badge>
              </dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">نتيجة الاختبار النهائي</dt>
              <dd className="font-semibold" dir="ltr">
                {cert.finalQuizScore}/{cert.finalQuizTotal} (
                {cert.finalQuizPercentage}%)
              </dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-muted-foreground">رقم الشهادة</dt>
              <dd className="font-mono text-xs" dir="ltr">
                {cert.certificateCode}
              </dd>
            </div>
          </dl>

          <div className="flex flex-col gap-2">
            <Button
              render={<a href={scanUrl} target="_blank" rel="noreferrer" />}
              nativeButton={false}
            >
              عرض الشهادة
            </Button>
            <Button
              render={<a href={`${scanUrl}?type=pdf`} />}
              nativeButton={false}
              variant="outline"
            >
              <Download />
              تحميل PDF
            </Button>
          </div>

          <div className="flex items-center justify-center">
            <Button
              render={<Link href="/verify" />}
              nativeButton={false}
              variant="ghost"
            >
              <ArrowRight />
              تحقق من شهادة أخرى
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}