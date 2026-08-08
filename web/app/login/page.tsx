import { Suspense } from "react"

import { LoginForm } from "@/components/auth/login-form"
import { Skeleton } from "@/components/ui/skeleton"

function LoginFormSkeleton() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <div className="flex flex-col items-center gap-2 text-center">
        <Skeleton className="h-9 w-24" />
        <Skeleton className="h-4 w-52" />
      </div>
      <div className="flex flex-col gap-1.5">
        <Skeleton className="h-4 w-28" />
        <Skeleton className="h-9 w-full rounded-3xl" />
      </div>
      <Skeleton className="h-9 w-full rounded-3xl" />
    </div>
  )
}

export default function LoginPage() {
  return (
    <main className="relative flex min-h-dvh items-center justify-center overflow-hidden px-4 py-12">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(60%_50%_at_50%_0%,color-mix(in_oklch,var(--primary)_10%,transparent),transparent)]"
      />
      <Suspense fallback={<LoginFormSkeleton />}>
        <LoginForm className="w-full max-w-sm" />
      </Suspense>
    </main>
  )
}
