"use client"

import { useEffect, useState } from "react"

import { Button } from "@/components/ui/button"
import { authClient } from "@/lib/auth-client"

export default function Page() {
  const { data: session, isPending } = authClient.useSession()
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    authClient.getAccessToken({ providerId: "telegram" }).then(console.log)
  }, [])

  const handleTelegramLogin = async () => {
    try {
      setIsSubmitting(true)
      await authClient.signIn.oauth2({
        providerId: "telegram",
        callbackURL: "/",
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleLogout = async () => {
    try {
      setIsSubmitting(true)
      await authClient.signOut()
    } finally {
      setIsSubmitting(false)
    }
  }

  if (isPending) {
    return (
      <main className="flex min-h-dvh items-center justify-center px-6">
        <p className="text-muted-foreground">جارٍ التحقق من الجلسة...</p>
      </main>
    )
  }

  if (!session) {
    return (
      <main className="flex min-h-dvh items-center justify-center px-6">
        <section className="w-full max-w-md border bg-card p-8 text-center">
          <h1 className="font-heading text-3xl text-foreground">مرحباً بك</h1>
          <p className="mt-3 text-sm text-muted-foreground">
            سجل دخولك باستخدام تيليجرام للمتابعة
          </p>
          <Button
            className="mt-6 w-full"
            onClick={handleTelegramLogin}
            disabled={isSubmitting}
          >
            تسجيل الدخول عبر تيليجرام
          </Button>
        </section>
      </main>
    )
  }

  return (
    <main className="flex min-h-dvh items-center justify-center px-6">
      <section className="w-full max-w-md border bg-card p-8">
        <h1 className="text-center font-heading text-3xl text-foreground">
          أهلاً، {session.user.name}
        </h1>

        <Button
          variant="outline"
          className="mt-6 w-full"
          onClick={handleLogout}
          disabled={isSubmitting}
        >
          تسجيل الخروج
        </Button>
      </section>
    </main>
  )
}
