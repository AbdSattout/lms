"use client"

import { useEffect } from "react"
import { ArrowRight, CheckCircle2, Smartphone } from "lucide-react"

const appUrl = "lms://billing/success"

export default function MobileBillingSuccessPage() {
  useEffect(() => {
    window.location.href = appUrl
  }, [])

  return (
    <main className="flex min-h-screen items-center justify-center bg-gray-50 p-4 dark:bg-[#0a0a0a]">
      <section className="w-full max-w-[26rem] rounded-3xl border border-gray-200 bg-white p-8 text-center shadow-2xl dark:border-gray-800 dark:bg-gray-900/70">
        <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-green-50 dark:bg-green-500/10">
          <CheckCircle2 className="h-10 w-10 text-green-600 dark:text-green-400" />
        </div>

        <h1 className="mb-2 font-heading text-2xl font-bold text-gray-950 dark:text-white">
          Payment completed
        </h1>
        <p className="mb-6 text-sm leading-6 text-gray-600 dark:text-gray-400">
          We are opening the LMS app to activate your subscription.
        </p>

        <a
          href={appUrl}
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-gray-950 px-5 py-3.5 text-sm font-bold text-white shadow-lg transition hover:bg-gray-800 active:scale-[0.98] dark:bg-white dark:text-gray-950 dark:hover:bg-gray-100"
        >
          <Smartphone className="h-4 w-4" />
          Open app
          <ArrowRight className="h-4 w-4" />
        </a>
      </section>
    </main>
  )
}
