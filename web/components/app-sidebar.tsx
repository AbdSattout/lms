"use client"

import * as React from "react"

import { NavMain } from "@/components/nav-main"
import { NavUser } from "@/components/nav-user"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { OrganizationResponse, User } from "@/lib/api/types"
import {
  GraduationCap,
  LayoutDashboardIcon,
  Settings,
  SquarePen,
} from "lucide-react"
import Link from "next/link"

export function AppSidebar({
  org,
  user,
  ...props
}: {
  org: OrganizationResponse
  user: User
} & React.ComponentProps<typeof Sidebar>) {
  const navItems = [
    {
      title: "نظرة عامة",
      url: `/${org?.slug}`,
      icon: <LayoutDashboardIcon />,
    },
    {
      title: "الدورات",
      url: `/${org?.slug}/courses`,
      icon: <GraduationCap />,
    },
    {
      title: "المنشورات",
      url: `/${org?.slug}/posts`,
      icon: <SquarePen />,
    },
    {
      title: "الاعدادات",
      url: `/${org?.slug}/settings`,
      icon: <Settings />,
    },
  ] as const

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
      <SidebarContent>
        <NavMain items={navItems} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={user} org={org} />
      </SidebarFooter>
    </Sidebar>
  )
}
