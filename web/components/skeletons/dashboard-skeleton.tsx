import { NavSkeleton } from "@/components/skeletons/nav-skeleton"
import { SidebarAccountDropdownSkeleton } from "@/components/skeletons/sidebar-account-dropdown-skeleton"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuItem,
  SidebarProvider,
} from "@/components/ui/sidebar"
import { Skeleton } from "@/components/ui/skeleton"
import { Loader } from "lucide-react"

export function DashboardSkeleton() {
  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <Sidebar collapsible="offcanvas" variant="inset">
        <SidebarHeader>
          <SidebarMenu>
            <SidebarMenuItem>
              <span className="font-heading text-2xl data-[slot=sidebar-menu-button]:p-1.5!">
                مسار
              </span>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarHeader>
        <SidebarContent className="pb-0">
          <NavSkeleton />
        </SidebarContent>
        <SidebarFooter>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarAccountDropdownSkeleton />
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarFooter>
      </Sidebar>
      <SidebarInset>
        <div className="flex h-(--header-height) shrink-0 items-center gap-2 border-b px-4 lg:px-6">
          <Skeleton className="size-4" />
          <div className="mx-2 h-4 w-px bg-border" />
          <Skeleton className="h-4 w-16" />
        </div>
        <div className="relative flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 p-4 md:gap-6 md:p-6">
              <div className="absolute inset-0 grid place-items-center">
                <Loader className="animate-spin" />
              </div>
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
