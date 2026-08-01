import { NextResponse } from "next/server"

import { getBackendJwtFromCookies } from "@/lib/auth/backend-jwt-cookie"

export async function GET() {
  const token = await getBackendJwtFromCookies()

  if (!token) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 })
  }

  return NextResponse.json(
    { token },
    { headers: { "Cache-Control": "no-store" } }
  )
}
