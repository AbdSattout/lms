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
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import {
  LayoutDashboardIcon,
  SquarePen,
  Settings,
  CommandIcon,
  GraduationCap,
} from "lucide-react"
import Link from "next/link"
const data = {
  user: {
    name: "اسم المنظمه",
    email: "mail@example.com",
    avatar: "/assets/icon-192.png",
  },
}
export function AppSidebar({
  orgSlug,
  ...props
}: { orgSlug?: string } & React.ComponentProps<typeof Sidebar>) {
  const navItems = [
    {
      title: "نظرة عامة",
      url: `/dashboard/${orgSlug}`,
      icon: <LayoutDashboardIcon />,
    },
    {
      title: "الدورات",
      url: `/dashboard/${orgSlug}/courses`,
      icon: <GraduationCap />,
    },
    {
      title: "المنشورات",
      url: `/dashboard/${orgSlug}/posts`,
      icon: <SquarePen />,
    },
    {
      title: "الاعدادات",
      url: `/dashboard/${orgSlug}/settings`,
      icon: <Settings />,
    },
  ]
  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              className="data-[slot=sidebar-menu-button]:p-1.5!"
              render={<Link href={`/dashboard/${orgSlug}`} />}
            >
              <CommandIcon className="size-5!" />
              <span className="text-xl font-bold text-primary">
                لوحة التحكم
              </span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={navItems} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={data.user} orgSlug={orgSlug} />
      </SidebarFooter>
    </Sidebar>
  )
}
