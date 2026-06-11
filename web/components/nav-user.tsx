"use client"

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar"
import { OrganizationResponse, User } from "@/lib/api/types"
import { LogOutIcon } from "lucide-react"
import { useRouter } from "next/navigation"
import { OrgAvatar } from "./org-avatar"

export function NavUser({
  user,
  org,
}: {
  user?: User
  org?: OrganizationResponse
}) {
  const { isMobile } = useSidebar()
  const router = useRouter()

  const handleLogout = async () => {
    await fetch("/api/auth/logout", { method: "POST" })
    router.push("/login")
  }

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <SidebarMenuButton size="lg" className="aria-expanded:bg-muted" />
            }
          >
            <OrgAvatar src={org?.image} name={org?.name} className="size-8" />
            <div className="grid flex-1 text-start text-sm leading-tight">
              <span className="truncate font-medium">
                {org?.name ?? org?.slug}
              </span>
              <span className="truncate text-xs text-foreground/70">
                {user?.name}
              </span>
            </div>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="min-w-56"
            side={isMobile ? "bottom" : "right"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuItem onClick={handleLogout}>
              <LogOutIcon />
              تسجيل الخروج
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}
