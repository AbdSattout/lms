"use client"

import { useEffect } from "react"
import { ArrowRight, Link2, Smartphone, UsersRound } from "lucide-react"

type InviteRedirectClientProps = {
  token: string
}

export function InviteRedirectClient({ token }: InviteRedirectClientProps) {
  const appUrl = `lms://invite/${encodeURIComponent(token)}`

  useEffect(() => {
    window.location.href = appUrl
  }, [appUrl])

  return (
    <main className="flex min-h-screen items-center justify-center bg-gray-50 p-4 dark:bg-[#0a0a0a]">
      <section className="w-full max-w-[26rem] rounded-3xl border border-gray-200 bg-white p-8 text-center shadow-2xl dark:border-gray-800 dark:bg-gray-900/70">
        <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-sky-50 dark:bg-sky-500/10">
          <UsersRound className="h-10 w-10 text-sky-700 dark:text-sky-300" />
        </div>

        <h1 className="mb-2 font-heading text-2xl font-bold text-gray-950 dark:text-white">
          دعوة للانضمام
        </h1>
        <p className="mb-5 text-sm leading-6 text-gray-600 dark:text-gray-400">
          نحاول فتح تطبيق مسار لقبول الدعوة. إذا لم يفتح التطبيق تلقائياً،
          اضغط الزر بالأسفل.
        </p>

        <div
          dir="ltr"
          className="mb-6 inline-flex max-w-full items-center gap-2 rounded-full border border-gray-200 bg-gray-50 px-3 py-2 text-xs font-semibold text-gray-600 dark:border-gray-800 dark:bg-gray-950 dark:text-gray-300"
        >
          <Link2 className="h-3.5 w-3.5 shrink-0" />
          <span className="truncate">{shortToken(token)}</span>
        </div>

        <a
          href={appUrl}
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-gray-950 px-5 py-3.5 text-sm font-bold text-white shadow-lg transition hover:bg-gray-800 active:scale-[0.98] dark:bg-white dark:text-gray-950 dark:hover:bg-gray-100"
        >
          <Smartphone className="h-4 w-4" />
          فتح التطبيق
          <ArrowRight className="h-4 w-4" />
        </a>
      </section>
    </main>
  )
}

function shortToken(token: string) {
  if (token.length <= 18) return token
  return `${token.slice(0, 8)}...${token.slice(-6)}`
}
