"use client"

import { useSearchParams } from "next/navigation"
import { useState } from "react"

import { Button } from "@/components/ui/button"
import { authClient } from "@/lib/auth-client"
import { resolveSafeCallbackUrl } from "@/lib/auth/callback-url"

export type LoginProvider = "google" | "telegram"

const providerLabels: Record<LoginProvider, string> = {
  google: "تسجيل الدخول عبر جوجل",
  telegram: "تسجيل الدخول عبر تيليجرام",
}

export function LoginButton({ provider }: { provider: LoginProvider }) {
  const searchParams = useSearchParams()
  const [isSubmitting, setIsSubmitting] = useState(false)

  const callbackUrl = resolveSafeCallbackUrl(searchParams.get("callbackUrl"))

  const handleLogin = async () => {
    try {
      setIsSubmitting(true)
      try {
        await authClient.signOut()
      } catch {} // ignore sign-out errors; the sign-in flow will replace the session

      const exchangeURL = `/api/auth/exchange?provider=${provider}&callbackUrl=${encodeURIComponent(callbackUrl)}`

      if (provider === "google") {
        await authClient.signIn.social({
          provider: "google",
          callbackURL: exchangeURL,
        })
      } else {
        await authClient.signIn.oauth2({
          providerId: "telegram",
          callbackURL: exchangeURL,
        })
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Button
      className="w-full"
      variant={provider === "google" ? "outline" : "default"}
      onClick={handleLogin}
      disabled={isSubmitting}
    >
      {isSubmitting ? "جاري تسجيل الدخول..." : providerLabels[provider]}
    </Button>
  )
}