"use client"

import * as React from "react"

import { Nav, NavItem } from "@/components/nav"
import { SidebarAccountDropdown } from "@/components/sidebar-account-dropdown"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import type { Route } from "next"
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
  const navItems: NavItem[] = [
    {
      title: "نظرة عامة",
      url: `/${org.slug}` as Route,
      icon: <LayoutDashboardIcon />,
    },
    {
      title: "الدورات",
      url: `/${org.slug}/courses` as Route,
      icon: <GraduationCap />,
    },
    {
      title: "المنشورات",
      url: `/${org.slug}/posts` as Route,
      icon: <SquarePen />,
    },
    {
      title: "الاعدادات",
      url: `/${org.slug}/settings` as Route,
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
            <SidebarAccountDropdown user={user} org={org} />
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  )
}
