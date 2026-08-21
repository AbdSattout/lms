import { getBackendJwtFromCookies } from "@/lib/auth/backend-jwt-cookie"

import { LandingPage } from "./home/landingpage-home"
import OrganizationsHome from "./home/organizations-home"

export default async function HomePage() {
  const token = await getBackendJwtFromCookies()

  if (token) {
    return <OrganizationsHome />
  }

  return <LandingPage />
}
