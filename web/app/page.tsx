import { headers } from "next/headers"
import { auth } from "@/lib/auth"

import { LandingPage } from "./home/landingpage-home"
import OrganizationsHome from "./home/organizations-home"

export default async function HomePage() {
  const session = await auth.api.getSession({
    headers: await headers(),
  })
  console.log("session", session)
  if (session?.user.name) {
    return <OrganizationsHome />
  }

  return <LandingPage />
}
