"use client"

import { Button } from "@/components/ui/button"
import { useState } from "react"

export default function Page() {
  const [status, setStatus] = useState("جاهز")
  const [result, setResult] = useState("")
  const [targetUrl, setTargetUrl] = useState("")

  const testApi = async () => {
    setStatus("جار الفحص...")
    setResult("")

    try {
      const response = await fetch("/api/test-api", {
        method: "GET",
        cache: "no-store",
      })
      const data = (await response.json()) as {
        ok: boolean
        target: string
        status: number | null
        result: string
      }
      setTargetUrl(data.target)
      setStatus(data.ok ? `متاح (${data.status ?? "-"})` : "غير متاح")
      setResult(data.result || "(استجابة فارغة)")
    } catch (error) {
      setStatus("فشل الطلب")
      setResult(error instanceof Error ? error.message : "خطأ غير معروف")
    }
  }

  return (
    <div className="flex min-h-svh items-center justify-center p-6">
      <div className="w-full max-w-xl rounded-xl border p-6 text-sm leading-loose">
        <h1 className="font-heading text-2xl">اختبار اتصال API</h1>
        <p className="text-muted-foreground">
          اضغط الزر لفحص الاتصال وإظهار نتيجة الاستجابة.
        </p>
        <Button className="mt-4" onClick={testApi}>
          اختبار الآن
        </Button>
        <div className="mt-4 space-y-1">
          <p className="flex justify-between">
            <span>الرابط:</span>
            <span className="font-mono">{targetUrl || "-"}</span>
          </p>
          <p>الحالة: {status}</p>
          <p>النتيجة:</p>
          <p
            className="justify-self-end break-all whitespace-pre-wrap"
            dir="ltr"
          >
            {result || "-"}
          </p>
        </div>
      </div>
    </div>
  )
}
