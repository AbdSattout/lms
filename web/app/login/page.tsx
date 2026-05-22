import { Suspense } from "react"

import { LoginButton } from "@/components/auth/login-button"
import { Skeleton } from "@/components/ui/skeleton"

export default function LoginPage() {
  return (
    <main className="flex min-h-dvh items-center justify-center">
      <div className="flex min-w-60 flex-col items-center gap-4">
        <h1 className="mb-3 font-heading text-4xl">تسجيل الدخول</h1>
        <Suspense fallback={<Skeleton className="h-10 w-full rounded-none" />}>
          <LoginButton />
        </Suspense>
      </div>
    </main>
  )
}
