"use client"

import { useSearchParams } from "next/navigation"
import { useState } from "react"

import { Button } from "@/components/ui/button"
import { authClient } from "@/lib/auth-client"
import { resolveSafeCallbackUrl } from "@/lib/auth/callback-url"

export function GoogleLoginButton() {
  const searchParams = useSearchParams()
  const [isSubmitting, setIsSubmitting] = useState(false)

  const callbackUrl = resolveSafeCallbackUrl(searchParams.get("callbackUrl"))

  const handleLogin = async () => {
    try {
      setIsSubmitting(true)
      await authClient.signIn.oauth2({
        providerId: "google",
        callbackURL: `/api/auth/exchange?callbackUrl=${encodeURIComponent(callbackUrl)}`,
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Button className="w-full" onClick={handleLogin} disabled={isSubmitting}>
      {isSubmitting ? "جاري تسجيل الدخول..." : "تسجيل الدخول عبر جوجل"}
    </Button>
  )
}
