import "server-only"

import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export async function getBetterAuthSession() {
  try {
    return auth.api.getSession({ headers: await headers() })
  } catch {
    return null
  }
}

export async function getOidcIdToken() {
  try {
    const tokens = await auth.api.getAccessToken({
      body: { providerId: "telegram" },
      headers: await headers(),
    })

    return tokens.idToken ?? null
  } catch {
    return null
  }
}
