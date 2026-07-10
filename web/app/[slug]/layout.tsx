import { Header } from "@/components/header"
import { OrgGuard } from "@/components/org-guard"
import { AppSidebar } from "@/components/sidebar"
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar"
import { api } from "@/lib/api"
import { Suspense } from "react"

async function DashboardShell({
  params,
  children,
}: {
  params: Promise<{ slug: string }>
  children: React.ReactNode
}) {
  const { slug } = await params
  const orgPromise = api.dashboard.organizations.bySlug(slug)

  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <Suspense fallback={null}>
        <OrgGuard promise={orgPromise} />
      </Suspense>
      <AppSidebar variant="inset" orgSlug={slug} orgPromise={orgPromise} />
      <SidebarInset>
        <Header orgPromise={orgPromise} />
        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 p-4 md:gap-6 md:p-6">
              {children}
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}

export default function DashboardLayout({
  params,
  children,
}: {
  params: Promise<{ slug: string }>
  children: React.ReactNode
}) {
  return (
    <Suspense fallback={null}>
      <DashboardShell params={params}>{children}</DashboardShell>
    </Suspense>
  )
}
