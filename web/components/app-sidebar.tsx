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

const data = {
  user: {
    name: "اسم المنظمه",
    email: "mail@example.com",
    avatar: "/assets/icon-192.png",
  },
  navMain: [
    {
      title: "نظرة عامة",
      url: "#",
      icon: <LayoutDashboardIcon />,
    },
    {
      title: "الدورات",
      url: "#",
      icon: <GraduationCap />,
    },
    {
      title: "المنشورات",
      url: "#",
      icon: <SquarePen />,
    },
    {
      title: "الاعدادات",
      url: "#",
      icon: <Settings />,
    },
  ],
}
export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              className="data-[slot=sidebar-menu-button]:p-1.5!"
              render={<a href="#" />}
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
        <NavMain items={data.navMain} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={data.user} />
      </SidebarFooter>
    </Sidebar>
  )
}
