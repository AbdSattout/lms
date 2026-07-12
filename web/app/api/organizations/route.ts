import { api } from "@/lib/api"

export async function GET() {
  const organizations = await api.organizations.list({
    onUnauthorized: "throw",
  })

  return Response.json(organizations)
}
