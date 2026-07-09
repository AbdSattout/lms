"use client"

import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import { Separator } from "@/components/ui/separator"
import { SidebarTrigger } from "@/components/ui/sidebar"
import { Route } from "next"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Fragment, Suspense } from "react"
import { Skeleton } from "./ui/skeleton"

const routeMapping: Record<string, string> = {
  posts: "المنشورات",
  courses: "الدورات",
  settings: "الإعدادات",
}

function BreadcrumbNav() {
  const pathname = usePathname()

  const segments = pathname.split("/").filter(Boolean)
  const start = Math.max(segments.indexOf("dashboard") + 1, 0)

  const breadcrumbs = segments.slice(start).map((segment, index) => ({
    href: `/${segments.slice(0, start + index + 1).join("/")}`,
    label: routeMapping[segment] ?? decodeURIComponent(segment),
  }))

  return (
    <Breadcrumb>
      <BreadcrumbList>
        {breadcrumbs.map(({ href, label }, index) => {
          const isLast = index === breadcrumbs.length - 1

          return (
            <Fragment key={href}>
              {index > 0 && <BreadcrumbSeparator />}

              <BreadcrumbItem>
                {isLast ? (
                  <BreadcrumbPage>{label}</BreadcrumbPage>
                ) : (
                  <BreadcrumbLink
                    render={(props) => <Link href={href as Route} {...props} />}
                  >
                    {label}
                  </BreadcrumbLink>
                )}
              </BreadcrumbItem>
            </Fragment>
          )
        })}
      </BreadcrumbList>
    </Breadcrumb>
  )
}

export function Header() {
  return (
    <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ms-1" />

        <Separator
          orientation="vertical"
          className="mx-2 h-4 data-vertical:self-auto"
        />

        <Suspense fallback={<Skeleton className="h-4 w-16" />}>
          <BreadcrumbNav />
        </Suspense>
      </div>
    </header>
  )
}
