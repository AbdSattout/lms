"use client"

import { useRouter, useSearchParams } from "next/navigation"
import { useEffect, useRef, useState } from "react"
import { toast } from "sonner"

import { LoginButton } from "@/components/auth/login-button"
import { Button } from "@/components/ui/button"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
  FieldSeparator,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { resolveSafeCallbackUrl } from "@/lib/auth/callback-url"
import { cn } from "@/lib/utils"

const RESEND_COOLDOWN_SECONDS = 60
const MAX_ATTEMPTS = 5
const REQUEST_TIMEOUT_MS = 20_000
const GENERIC_ERROR_MESSAGE = "حدث خطأ ما، حاول مرة أخرى"
type Step = "email" | "code" | "admin"

async function postJson(url: string, body: unknown) {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS)

  try {
    return await fetch(url, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
      signal: controller.signal,
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === "AbortError") {
      throw new Error("انتهت مهلة الطلب، تحقق من اتصالك وحاول مرة أخرى.")
    }

    throw error
  } finally {
    clearTimeout(timer)
  }
}

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<"div">) {
  const router = useRouter()
  const searchParams = useSearchParams()

  const callbackUrl = resolveSafeCallbackUrl(searchParams.get("callbackUrl"))
  const authError = searchParams.get("error")

  useEffect(() => {
    if (!authError) {
      return
    }

    toast.error(authError)
  }, [authError])

  const [step, setStep] = useState<Step>("email")
  const [email, setEmail] = useState("")
  const [code, setCode] = useState("")
  const [password, setPassword] = useState("")
  const [attempts, setAttempts] = useState(0)
  const [resendIn, setResendIn] = useState(0)
  const [isSending, setIsSending] = useState(false)
  const [isVerifying, setIsVerifying] = useState(false)
  const [isAdminLoggingIn, setIsAdminLoggingIn] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const lastAutoSubmittedCodeRef = useRef("")

  const [clickCount, setClickCount] = useState(0)
  const clickTimerRef = useRef<NodeJS.Timeout | null>(null)

  const isEmailValid = /\S+@\S+\.\S+/.test(email)

  useEffect(() => {
    if (resendIn <= 0) {
      return
    }

    const timer = setInterval(() => setResendIn((current) => current - 1), 1000)

    return () => clearInterval(timer)
  }, [resendIn])

  const resetToEmailStep = () => {
    setStep("email")
    setCode("")
    setPassword("")
    setAttempts(0)
    setResendIn(0)
    setError(null)
    setClickCount(0)
    lastAutoSubmittedCodeRef.current = ""
  }

  const handleAdminClick = () => {
    setClickCount((prev) => {
      const newCount = prev + 1

      if (newCount === 5) {
        setClickCount(0)
        setStep("admin")
        setEmail("")
        setPassword("")
        setError(null)
        toast.info("تم تفعيل وضع تسجيل دخول المشرف", {
          description: "أدخل بريد المشرف وكلمة المرور",
        })
        return 0
      }

      if (clickTimerRef.current) {
        clearTimeout(clickTimerRef.current)
      }

      clickTimerRef.current = setTimeout(() => {
        setClickCount(0)
      }, 3000)

      return newCount
    })
  }

  const handleAdminLogin = async () => {
    if (!isEmailValid || !password || isAdminLoggingIn) {
      return
    }

    try {
      setIsAdminLoggingIn(true)
      setError(null)

      console.log("Sending admin login request:", {
        email: email.trim(),
        password: password,
      })

      const response = await postJson("/api/auth/admin", {
        email: email.trim(),
        password: password,
      })

      console.log("Admin login response status:", response.status)

      const data = await response.json()
      console.log("Admin login response data:", data)

      if (!response.ok) {
        throw new Error(
          data.message ||
            (response.status === 401
              ? toast.error("بيانات المشرف غير صحيحة")
              : toast.error("حدث خطأ ما، حاول مرة أخرى"))
        )
      }

      console.log("Admin login successful:", data)
      toast.success("تم تسجيل دخول المشرف بنجاح")
      router.replace("/admin/reports" as never)
    } catch (error) {
      console.error("Admin login error:", error)
      toast.error("حدث خطأ ما، حاول مرة أخرى")
    } finally {
      setIsAdminLoggingIn(false)
    }
  }
  const handleSendCode = async () => {
    if (!isEmailValid || isSending) {
      return
    }

    try {
      setIsSending(true)
      setError(null)

      const response = await postJson("/api/auth/email/request-otp", {
        email: email.trim(),
      })

      if (response.status === 429) {
        toast.info("تم إرسال رمز التحقق مسبقًا، تحقق من بريدك الإلكتروني.")
        setCode("")
        setAttempts(0)
        setResendIn(RESEND_COOLDOWN_SECONDS)
        setStep("code")
        lastAutoSubmittedCodeRef.current = ""
        return
      }

      if (!response.ok) {
        throw new Error(GENERIC_ERROR_MESSAGE)
      }

      setCode("")
      setAttempts(0)
      setResendIn(RESEND_COOLDOWN_SECONDS)
      setStep("code")
      lastAutoSubmittedCodeRef.current = ""
    } catch (error) {
      setError(error instanceof Error ? error.message : GENERIC_ERROR_MESSAGE)
    } finally {
      setIsSending(false)
    }
  }

  const handleVerify = async () => {
    if (!code || isVerifying) {
      return
    }

    const nextAttempts = attempts + 1

    try {
      setIsVerifying(true)
      setError(null)

      const response = await postJson("/api/auth/email/verify-otp", {
        email: email.trim(),
        code: code.trim(),
      })

      if (!response.ok) {
        if (response.status === 429 || nextAttempts >= MAX_ATTEMPTS) {
          toast.error(
            "تجاوزت الحد المسموح من المحاولات، سيتم إلغاء الرمز. أعد طلب رمز جديد وحاول مجددًا."
          )
          resetToEmailStep()
          return
        }

        setAttempts(nextAttempts)

        const data = await response.json().catch(() => null)

        throw new Error(
          response.status === 400
            ? "رمز التحقق غير صحيح أو منتهي."
            : typeof data?.message === "string" && data.message
              ? data.message
              : GENERIC_ERROR_MESSAGE
        )
      }

      router.replace(callbackUrl as never)
    } catch (error) {
      setError(error instanceof Error ? error.message : GENERIC_ERROR_MESSAGE)
    } finally {
      setIsVerifying(false)
    }
  }

  useEffect(() => {
    if (
      code.length === 6 &&
      !isVerifying &&
      lastAutoSubmittedCodeRef.current !== code
    ) {
      lastAutoSubmittedCodeRef.current = code
      void handleVerify()
    }
  }, [code, isVerifying])

  // Cleanup timer on unmount
  useEffect(() => {
    return () => {
      if (clickTimerRef.current) {
        clearTimeout(clickTimerRef.current)
      }
    }
  }, [])

  return (
    <div className={cn("flex flex-col gap-6", className)} {...props}>
      <form
        onSubmit={(event) => {
          event.preventDefault()

          if (step === "code") {
            void handleVerify()
          } else if (step === "admin") {
            void handleAdminLogin()
          } else {
            void handleSendCode()
          }
        }}
      >
        <FieldGroup className="gap-4">
          <div className="flex flex-col items-center gap-2 text-center">
            <span
              className="font-heading text-4xl"
              onClick={handleAdminClick}
              title={clickCount > 0 ? `${clickCount}/5` : undefined}
            >
              مسار
            </span>
            <FieldDescription>
              {step === "code" ? (
                <>
                  أُرسل الرمز إلى{" "}
                  <span dir="ltr" className="font-medium text-foreground">
                    {email.trim()}
                  </span>
                </>
              ) : step === "admin" ? (
                "تسجيل دخول المشرف - أدخل بيانات المشرف"
              ) : (
                "أدخل بريدك الإلكتروني وسنرسل إليك رمز تحقق"
              )}
            </FieldDescription>
          </div>

          {step === "code" ? (
            <>
              <Field data-invalid={!!error}>
                <FieldLabel htmlFor="otp-code">رمز التحقق</FieldLabel>
                <Input
                  id="otp-code"
                  autoFocus
                  dir="ltr"
                  className="text-center tracking-[0.35em]"
                  inputMode="numeric"
                  autoComplete="one-time-code"
                  maxLength={6}
                  pattern="[0-9]*"
                  placeholder="••••••"
                  aria-invalid={!!error}
                  value={code}
                  onChange={(event) =>
                    setCode(event.target.value.replace(/\D/g, "").slice(0, 6))
                  }
                />
                {error ? <FieldError>{error}</FieldError> : null}
              </Field>

              <Field>
                <Button
                  type="submit"
                  className="w-full"
                  disabled={code.length !== 6 || isVerifying}
                >
                  {isVerifying ? "جاري تسجيل الدخول..." : "تأكيد تسجيل الدخول"}
                </Button>
                <div className="flex items-center justify-between gap-2">
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="px-2"
                    onClick={resetToEmailStep}
                  >
                    تغيير البريد الإلكتروني
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="px-2"
                    disabled={resendIn > 0}
                    onClick={() => void handleSendCode()}
                  >
                    {resendIn > 0
                      ? `إعادة الإرسال خلال ${resendIn} ث`
                      : "إعادة إرسال الرمز"}
                  </Button>
                </div>
              </Field>
            </>
          ) : step === "admin" ? (
            <>
              <Field data-invalid={!!error}>
                <FieldLabel htmlFor="admin-email">بريد المشرف</FieldLabel>
                <Input
                  id="admin-email"
                  autoFocus
                  type="email"
                  autoComplete="email"
                  dir="ltr"
                  className="text-left"
                  placeholder="admin@example.com"
                  aria-invalid={!!error}
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                />
              </Field>

              <Field data-invalid={!!error}>
                <FieldLabel htmlFor="admin-password">كلمة المرور</FieldLabel>
                <Input
                  id="admin-password"
                  type="password"
                  autoComplete="current-password"
                  dir="ltr"
                  className="text-left"
                  placeholder="••••••••"
                  aria-invalid={!!error}
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                />
                {error ? <FieldError>{error}</FieldError> : null}
              </Field>

              <Field>
                <Button
                  type="submit"
                  className="w-full"
                  disabled={!isEmailValid || !password || isAdminLoggingIn}
                >
                  {isAdminLoggingIn
                    ? "جاري تسجيل الدخول..."
                    : "تسجيل دخول المشرف"}
                </Button>
                <div className="flex justify-center">
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="px-2"
                    onClick={resetToEmailStep}
                  >
                    العودة لتسجيل الدخول العادي
                  </Button>
                </div>
              </Field>
            </>
          ) : (
            <>
              <Field data-invalid={!!error}>
                <FieldLabel htmlFor="login-email">البريد الإلكتروني</FieldLabel>
                <Input
                  id="login-email"
                  autoFocus
                  type="email"
                  autoComplete="email"
                  dir="ltr"
                  className="text-left"
                  placeholder="you@example.com"
                  aria-invalid={!!error}
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                />
                {error ? <FieldError>{error}</FieldError> : null}
              </Field>

              <Field>
                <Button
                  type="submit"
                  className="w-full"
                  disabled={!isEmailValid || isSending}
                >
                  {isSending ? "جاري الإرسال..." : "إرسال رمز التحقق"}
                </Button>
              </Field>
            </>
          )}

          {step !== "admin" && (
            <>
              <FieldSeparator>أو</FieldSeparator>

              <Field className="grid gap-4 sm:grid-cols-2">
                <LoginButton provider="telegram" />
                <LoginButton provider="google" />
              </Field>
            </>
          )}
        </FieldGroup>
      </form>
    </div>
  )
}
