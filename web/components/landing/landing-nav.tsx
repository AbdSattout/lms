"use client"

import type { Route } from "next"
import Link from "next/link"
import { Menu } from "lucide-react"

import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"

const links = [
  {
    label: "كيف يعمل",
    href: "#how-it-works",
  },
  {
    label: "التجربة",
    href: "#experience",
  },
  {
    label: "للمؤسسات",
    href: "#organizations",
  },
]

export function LandingNavbar() {
  return (
    <header
      dir="rtl"
      className="sticky top-0 z-50 border-b border-border/40 bg-background/85 backdrop-blur-xl select-none"
    >
      <div className="relative mx-auto grid h-16 w-full max-w-7xl grid-cols-[1fr_auto_1fr] items-center px-4 md:px-6">
        <div className="justify-self-start">
          <Link href="/" className="group flex items-center gap-3">
            <span className="text-xl font-black tracking-tight">مسار</span>
          </Link>
        </div>

        <nav className="hidden items-center gap-1 md:flex">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="rounded-lg px-5 py-2.5 text-sm font-semibold text-muted-foreground transition-all hover:bg-muted hover:text-foreground"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="hidden justify-self-end md:block">
          <Link
            href={"/login" as Route}
            className="inline-flex h-10 items-center justify-center rounded-lg bg-primary px-5 text-sm font-bold text-primary-foreground shadow-sm transition-all hover:bg-primary/90 hover:shadow-md"
          >
            ابدأ التعلم
          </Link>
        </div>

        <Sheet>
          <SheetTrigger
            aria-label="فتح القائمة"
            className="flex h-10 w-10 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:bg-muted hover:text-foreground md:hidden"
          >
            <Menu className="h-5 w-5" />
          </SheetTrigger>

          <SheetContent side="right" dir="rtl" className="w-75">
            <div className="flex h-full flex-col pt-6">
              <div className="flex items-center gap-3">
                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary text-primary-foreground">
                  <span className="font-black">م</span>
                </div>

                <span className="text-xl font-black">مسار</span>
              </div>

              <nav className="mt-10 flex flex-col gap-1">
                {links.map((link) => (
                  <a
                    key={link.href}
                    href={link.href}
                    className="rounded-lg px-3 py-3 text-sm font-semibold text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                  >
                    {link.label}
                  </a>
                ))}
              </nav>

              <div className="mt-auto flex flex-col gap-2">
                <Link
                  href={"/login" as Route}
                  className="inline-flex h-11 items-center justify-center rounded-lg border bg-background px-4 text-sm font-bold"
                >
                  تسجيل الدخول
                </Link>

                <Link
                  href={"/login" as Route}
                  className="inline-flex h-11 items-center justify-center rounded-lg bg-primary px-4 text-sm font-bold text-primary-foreground"
                >
                  ابدأ التعلم
                </Link>
              </div>
            </div>
          </SheetContent>
        </Sheet>
      </div>
    </header>
  )
}
