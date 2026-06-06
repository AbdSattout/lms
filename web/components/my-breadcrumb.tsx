"use client"

import React from "react"
import { usePathname } from "next/navigation"
import Link from "next/link"
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"

const routeMapping: Record<string, string> = {
  posts: "المنشورات",
  courses: "الدورات",
  settings: "الإعدادات",
}

export function MyBreadcrumb() {
  const pathname = usePathname()

  const segments = pathname.split("/").filter(Boolean)

  const dashboardIndex = segments.indexOf("dashboard")
  const visibleSegments =
    dashboardIndex !== -1 ? segments.slice(dashboardIndex + 1) : segments
  return (
    <Breadcrumb dir="rtl">
      <BreadcrumbList>
        {visibleSegments.map((segment, index) => {
          const actualIndexInFullArray =
            dashboardIndex !== -1 ? dashboardIndex + 1 + index : index
          const href = `/${segments.slice(0, actualIndexInFullArray + 1).join("/")}`

          const isFirst = index === 0
          const isLast = index === visibleSegments.length - 1

          const label = routeMapping[segment] || decodeURIComponent(segment)

          return (
            <React.Fragment key={href}>
              {!isFirst && <BreadcrumbSeparator />}

              <BreadcrumbItem>
                {isLast ? (
                  <BreadcrumbPage>{label}</BreadcrumbPage>
                ) : (
                  <BreadcrumbLink
                    render={(props) => <Link href={href} {...props} />}
                  >
                    {label}
                  </BreadcrumbLink>
                )}
              </BreadcrumbItem>
            </React.Fragment>
          )
        })}
      </BreadcrumbList>
    </Breadcrumb>
  )
}
