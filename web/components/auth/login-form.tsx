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

const GENERIC_ERROR_MESSAGE = "حدث خطأ ما، حاول مرة أخرى."

type Step = "email" | "code"

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
  const [attempts, setAttempts] = useState(0)
  const [resendIn, setResendIn] = useState(0)
  const [isSending, setIsSending] = useState(false)
  const [isVerifying, setIsVerifying] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const lastAutoSubmittedCodeRef = useRef("")

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
    setAttempts(0)
    setResendIn(0)
    setError(null)
    lastAutoSubmittedCodeRef.current = ""
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
        // A code was already sent recently - tell the user before switching
        // to the code step (a valid OTP for this email already exists).
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
        throw new Error(
          response.status === 400
            ? "رمز التحقق غير صحيح أو منتهي."
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

  return (
    <div className={cn("flex flex-col gap-6", className)} {...props}>
      <form
        onSubmit={(event) => {
          event.preventDefault()

          if (step === "code") {
            void handleVerify()
          } else {
            void handleSendCode()
          }
        }}
      >
        <FieldGroup className="gap-4">
          <div className="flex flex-col items-center gap-2 text-center">
            <span className="font-heading text-4xl">مسار</span>
            <FieldDescription>
              {step === "code" ? (
                <>
                  أُرسل الرمز إلى{" "}
                  <span dir="ltr" className="font-medium text-foreground">
                    {email.trim()}
                  </span>
                </>
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

          <FieldSeparator>أو</FieldSeparator>

          <Field className="grid gap-4 sm:grid-cols-2">
            <LoginButton provider="telegram" />
            <LoginButton provider="google" />
          </Field>
        </FieldGroup>
      </form>
    </div>
  )
}
