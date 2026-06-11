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
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar"
import { OrganizationResponse, User } from "@/lib/api/types"
import { Loader2Icon, LogOutIcon } from "lucide-react"
import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import { OrgAvatar } from "./org-avatar"
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar"
import { Button } from "./ui/button"

export function SidebarAccountDropdown({
  user,
  org,
}: {
  user: User
  org: OrganizationResponse
}) {
  const { isMobile } = useSidebar()
  const router = useRouter()
  const [organizations, setOrganizations] = useState<OrganizationResponse[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch("/api/organizations")
      .then((res) => res.json())
      .then((data) => {
        setOrganizations(data)
        setLoading(false)
      })
      .catch(() => setLoading(false))
  }, [])

  const handleLogout = async () => {
    await fetch("/api/auth/logout", { method: "POST" })
    router.push("/login")
  }

  const filteredOrgs = organizations.filter((o) => o.slug !== org.slug)

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          <SidebarMenuButton size="lg" className="aria-expanded:bg-muted" />
        }
      >
        <OrgAvatar src={org.image} name={org.name} className="size-8" />
        <div className="grid flex-1 text-start text-sm leading-tight">
          <span className="truncate font-medium">{org.name ?? org.slug}</span>
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
          {loading ? (
            <div className="flex items-center justify-center gap-2 p-3 text-muted-foreground">
              <Loader2Icon className="size-4 animate-spin" />
            </div>
          ) : (
            <>
              <DropdownMenuLabel>المنظمات</DropdownMenuLabel>
              {filteredOrgs.map((o) => (
                <DropdownMenuItem
                  key={o.id ?? o.slug}
                  onClick={() => router.push(`/${o.slug}`)}
                  className="cursor-pointer"
                >
                  <OrgAvatar src={o.image} name={o.name ?? o.slug} />
                  <span className="truncate">{o.name ?? o.slug}</span>
                </DropdownMenuItem>
              ))}
            </>
          )}
          {(loading || filteredOrgs.length) && <DropdownMenuSeparator />}
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
