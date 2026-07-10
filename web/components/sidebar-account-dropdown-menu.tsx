"use client"

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { SidebarMenuButton, useSidebar } from "@/components/ui/sidebar"
import { OrganizationResponse, User } from "@/lib/api/types"
import { LogOutIcon } from "lucide-react"
import { useRouter } from "next/navigation"

import { OrgAvatar } from "./org-avatar"
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar"
import { Button } from "./ui/button"

export function SidebarAccountDropdownMenu({
  user,
  org,
  organizations,
}: {
  user: User
  org: OrganizationResponse
  organizations: OrganizationResponse[]
}) {
  const { isMobile } = useSidebar()
  const router = useRouter()

  const handleLogout = async () => {
    await fetch("/api/auth/logout", { method: "POST" })
    router.push("/login")
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          <SidebarMenuButton size="lg" className="aria-expanded:bg-muted" />
        }
      >
        <OrgAvatar src={org.image} name={org.name} className="size-8" />
        <div className="grid flex-1 text-start text-sm leading-tight">
          <span className="truncate font-medium">{org.name}</span>
          <span className="truncate text-xs text-foreground/70">
            {user.name}
          </span>
        </div>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        className="min-w-56"
        side={isMobile ? "bottom" : "right"}
        align="end"
        sideOffset={4}
      >
        <DropdownMenuGroup>
          <DropdownMenuLabel>المنظمات</DropdownMenuLabel>
          {organizations.map((o) => (
            <DropdownMenuItem
              key={o.id}
              onClick={() => router.push(`/${o.slug}`)}
              className="cursor-pointer"
            >
              <OrgAvatar src={o.image} name={o.name} />
              <span className="truncate">{o.name}</span>
            </DropdownMenuItem>
          ))}
          {organizations.length > 0 && <DropdownMenuSeparator />}
          <DropdownMenuLabel>الحساب الشخصي</DropdownMenuLabel>
          <div className="flex items-center gap-2 text-start text-sm">
            <Avatar className="size-8">
              <AvatarImage src={user.picture} alt={user.name} />
              <AvatarFallback className="rounded-lg">
                {user.name?.charAt(0).toUpperCase() ?? "?"}
              </AvatarFallback>
            </Avatar>
            <div className="grid flex-1 text-start text-sm leading-tight">
              <span className="truncate font-medium">{user.name}</span>
            </div>
            <Button variant="ghost" size="icon" onClick={handleLogout}>
              <LogOutIcon />
            </Button>
          </div>
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
