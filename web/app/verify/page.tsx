"use client"

import { useEffect, useRef, useState } from "react"
import { useRouter } from "next/navigation"
import type { Route } from "next"
import Link from "next/link"
import { Html5Qrcode } from "html5-qrcode"
import {
  ArrowRight,
  KeyRound,
  QrCode,
  ShieldCheck,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"
import { normalizeCertificateCode } from "@/lib/certificate/verify-utils"

type Mode = "input" | "scan"

const QR_READER_ID = "qr-code-reader"

function isCameraAvailable() {
  return (
    typeof navigator !== "undefined" &&
    navigator.mediaDevices != null &&
    typeof navigator.mediaDevices.getUserMedia === "function"
  )
}

function cameraErrorMessage(err: unknown): string {
  const NOT_SUPPORTED =
    "المتصفح لا يدعم تشغيل الكاميرا هنا، أو الصفحة غير متاحة عبر HTTPS/العنوان المحلي. جرّب إدخال الرمز يدويًا."
  const PERMISSION_DENIED =
    "تم رفض إذن الكاميرا. فعّل الإذن في إعدادات المتصفح ثم أعد المحاولة، أو أدخل الرمز يدويًا."
  const NO_CAMERA =
    "لم يتم العثور على كاميرا متاحة. يمكنك إدخال الرمز يدويًا."

  if (!isCameraAvailable()) return NOT_SUPPORTED

  const name =
    err && typeof err === "object" && "name" in (err as object)
      ? String((err as DOMException).name)
      : typeof err === "string"
        ? err
        : ""

  if (
    name === "NotAllowedError" ||
    name === "PermissionDeniedError" ||
    name === "SecurityError"
  ) {
    return PERMISSION_DENIED
  }
  if (
    name === "NotFoundError" ||
    name === "DevicesNotFoundError" ||
    name === "OverconstrainedError"
  ) {
    return NO_CAMERA
  }
  if (
    name === "Camera streaming not supported by the browser." ||
    name === "Camera streaming not supported by the browser"
  ) {
    return NOT_SUPPORTED
  }
  return "تعذر فتح الكاميرا. تحقق من الإذن ثم أعد المحاولة، أو أدخل الرمز يدويًا."
}

async function disposeScanner(scanner: Html5Qrcode | null): Promise<void> {
  if (!scanner) return
  try {
    if (scanner.isScanning) {
      await scanner.stop()
    }
  } catch {
    // Scanner already stopped — ignore.
  }
  try {
    scanner.clear()
  } catch {
    // Element already gone — ignore.
  }
}

export default function VerifyEntryPage() {
  const router = useRouter()

  const [mode, setMode] = useState<Mode>("input")
  const [retryKey, setRetryKey] = useState(0)
  const [code, setCode] = useState("")
  const [formError, setFormError] = useState<string | null>(null)
  const [scanError, setScanError] = useState<string | null>(null)

  const scannerRef = useRef<Html5Qrcode | null>(null)

  useEffect(() => {
    if (mode === "input") {
      setScanError(null)
      return
    }

    setScanError(null)

    if (!isCameraAvailable()) {
      setScanError(cameraErrorMessage(null))
      return
    }

    const scanner = new Html5Qrcode(QR_READER_ID, { verbose: false })
    scannerRef.current = scanner
    let disposed = false

    scanner
      .start(
        { facingMode: "environment" },
        {
          fps: 10,
          qrbox: { width: 240, height: 240 },
          aspectRatio: 1,
        },
        (decodedText) => {
          if (disposed) return
          const normalized = normalizeCertificateCode(decodedText)
          if (!normalized) return
          disposeScanner(scanner).then(() => {
            if (disposed) return
            router.push(`/verify/${normalized}` as Route)
          })
        },
        () => {}
      )
      .catch((err: unknown) => {
        if (disposed) return
        setScanError(cameraErrorMessage(err))
      })

    return () => {
      disposed = true
      if (scannerRef.current === scanner) scannerRef.current = null
      void disposeScanner(scanner)
    }
  }, [mode, retryKey, router])

  useEffect(
    () => () => {
      void disposeScanner(scannerRef.current)
      scannerRef.current = null
    },
    []
  )

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const normalized = normalizeCertificateCode(code)
    if (!normalized) {
      setFormError("رمز الشهادة غير صالح. تأكد من كتابته بشكل صحيح.")
      return
    }
    router.push(`/verify/${normalized}` as Route)
  }

  return (
    <div
      dir="rtl"
      className="flex min-h-dvh items-center justify-center bg-muted/30 p-4"
    >
      <Card className="w-full max-w-md">
        <CardHeader className="justify-items-center items-center text-center">
          <div className="mb-2 flex size-12 items-center justify-center rounded-full bg-primary/10">
            <ShieldCheck className="size-6 text-primary" />
          </div>
          <CardTitle className="text-xl">التحقق من الشهادة</CardTitle>
          <CardDescription>
            أدخل رمز الشهادة أو امسح رمز QR الظاهر على الشهادة للتحقق من
            صحتها في منصة مسار
          </CardDescription>
        </CardHeader>

        <CardContent className="flex flex-col gap-4">
          <div className="flex items-center gap-1 rounded-full bg-muted p-1 text-sm">
            <button
              type="button"
              onClick={() => setMode("input")}
              className={cn(
                "flex flex-1 items-center justify-center gap-2 rounded-full px-3 py-1.5 font-medium transition-colors",
                mode === "input"
                  ? "bg-background text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              <KeyRound className="size-4" />
              إدخال الرمز
            </button>
            <button
              type="button"
              onClick={() => setMode("scan")}
              className={cn(
                "flex flex-1 items-center justify-center gap-2 rounded-full px-3 py-1.5 font-medium transition-colors",
                mode === "scan"
                  ? "bg-background text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              <QrCode className="size-4" />
              مسح QR
            </button>
          </div>

          {mode === "input" ? (
            <form onSubmit={handleSubmit} className="flex flex-col gap-3">
              <div className="flex flex-col gap-1.5">
                <Input
                  dir="ltr"
                  value={code}
                  onChange={(e) => {
                    setCode(e.target.value)
                    setFormError(null)
                  }}
                  placeholder="أدخل رمز الشهادة"
                  className="text-center font-mono text-base tracking-widest"
                  aria-label="رمز الشهادة"
                  aria-invalid={formError ? true : undefined}
                />
                {formError ? (
                  <p className="text-sm text-destructive">{formError}</p>
                ) : null}
              </div>
              <Button type="submit">تحقق</Button>
            </form>
          ) : (
            <div className="flex flex-col gap-3">
              <div
                key={`${mode}-${retryKey}`}
                id={QR_READER_ID}
                className="w-full overflow-hidden rounded-3xl border bg-background"
              />
              {scanError ? (
                <p className="text-sm text-destructive">{scanError}</p>
              ) : (
                <p className="text-center text-sm text-muted-foreground">
                  وجّه الكاميرا نحو رمز QR الظاهر على الشهادة
                </p>
              )}
              <Button
                type="button"
                variant="outline"
                onClick={() => setRetryKey((k) => k + 1)}
                disabled={!scanError || !isCameraAvailable()}
              >
                إعادة المحاولة
              </Button>
            </div>
          )}

          <div className="flex items-center justify-center">
            <Button
              render={(props) => <Link href="/" {...props} />}
              nativeButton={false}
              variant="ghost"
            >
              <ArrowRight />
              العودة للرئيسية
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}