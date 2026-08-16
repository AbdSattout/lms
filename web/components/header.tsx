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
import type { OrganizationResponse } from "@/lib/api/types"
import { Route } from "next"
import Link from "next/link"
import { Fragment, Suspense, useContext, use } from "react"
import { Skeleton } from "./ui/skeleton"
import { BreadcrumbContext } from "./breadcrumb-context"
import { JoinRequestsNotification } from "./ui/join-request-notification-button"

function BreadcrumbNav({
  orgPromise,
}: {
  orgPromise: Promise<OrganizationResponse>
}) {
  const org = use(orgPromise)
  const { trail } = useContext(BreadcrumbContext)

  return (
    <Breadcrumb>
      <BreadcrumbList>
        <BreadcrumbItem>
          <BreadcrumbLink
            render={(props) => (
              <Link href={`/${org.slug}` as Route} {...props} />
            )}
          >
            {org.name}
          </BreadcrumbLink>
        </BreadcrumbItem>
        {trail.map((item, index) => (
          <Fragment key={index}>
            <BreadcrumbSeparator />
            <BreadcrumbItem>
              {item.href ? (
                <BreadcrumbLink
                  render={(props) => (
                    <Link href={item.href as Route} {...props} />
                  )}
                >
                  {item.label}
                </BreadcrumbLink>
              ) : (
                <BreadcrumbPage>{item.label}</BreadcrumbPage>
              )}
            </BreadcrumbItem>
          </Fragment>
        ))}
      </BreadcrumbList>
    </Breadcrumb>
  )
}

export function Header({
  orgPromise,
  orgSlug,
}: {
  orgPromise: Promise<OrganizationResponse>
  orgSlug: string
}) {
  return (
    <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ms-1" />

        <Separator
          orientation="vertical"
          className="mx-2 h-4 data-vertical:self-auto"
        />

        <Suspense fallback={<Skeleton className="h-4 w-16" />}>
          <BreadcrumbNav orgPromise={orgPromise} />

          <div className="absolute left-0">
            <JoinRequestsNotification slug={orgSlug} />
          </div>
        </Suspense>
      </div>
    </header>
  )
}
