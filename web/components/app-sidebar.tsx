import * as React from "react"
import { Suspense } from "react"

import { Nav, NavItem } from "@/components/nav"
import { SidebarAccountDropdown } from "@/components/sidebar-account-dropdown"
import { SidebarAccountDropdownSkeleton } from "@/components/skeletons/sidebar-account-dropdown-skeleton"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import type { OrganizationResponse } from "@/lib/api/types"
import {
  GraduationCap,
  LayoutDashboardIcon,
  Settings,
  SquarePen,
} from "lucide-react"
import type { Route } from "next"
import Link from "next/link"

export function AppSidebar({
  orgSlug,
  orgPromise,
  ...props
}: {
  orgSlug: string
  orgPromise: Promise<OrganizationResponse>
} & React.ComponentProps<typeof Sidebar>) {
  const navItems: NavItem[] = [
    {
      title: "نظرة عامة",
      url: `/${orgSlug}` as Route,
      icon: <LayoutDashboardIcon />,
    },
    {
      title: "الدورات",
      url: `/${orgSlug}/courses` as Route,
      icon: <GraduationCap />,
    },
    {
      title: "المنشورات",
      url: `/${orgSlug}/posts` as Route,
      icon: <SquarePen />,
    },
    {
      title: "الاعدادات",
      url: `/${orgSlug}/settings` as Route,
      icon: <Settings />,
    },
  ]

  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <Link
              className="font-heading text-2xl data-[slot=sidebar-menu-button]:p-1.5!"
              href="/"
            >
              مسار
            </Link>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent className="pb-0">
        <Nav items={navItems} />
      </SidebarContent>
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <Suspense fallback={<SidebarAccountDropdownSkeleton />}>
              <SidebarAccountDropdown orgPromise={orgPromise} />
            </Suspense>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  )
}
