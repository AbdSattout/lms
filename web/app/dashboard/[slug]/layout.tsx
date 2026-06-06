import { AppSidebar } from "@/components/app-sidebar"
import { SiteHeader } from "@/components/site-header"
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar"
import { api } from "@/lib/api"
import { notFound, redirect } from "next/navigation"

export default async function DashboardLayout({
  params,
  children,
}: {
  params: Promise<{ slug: string }>
  children: React.ReactNode
}) {
  const { slug } = await params
  try{
    const org=await api.organizations.bySlug(slug);
    if(!org){
      notFound();
    }
  } catch (error:unknown) {
    console.error("Organization layout auth error:", error)

if (typeof error === "object" && error !== null) {
    
    if ("status" in error) {
      const status = (error as { status: unknown }).status;
    if (status === 401) {
      redirect("/")
    }
  }}
    notFound()
  }
  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <AppSidebar variant="inset" orgSlug={slug} />
      <SidebarInset>
        <SiteHeader />
        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              {children}
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
