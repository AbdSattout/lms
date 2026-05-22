import { NextResponse } from "next/server"

import { clearBackendJwtCookie } from "@/lib/auth/backend-jwt-cookie"

export async function POST() {
  await clearBackendJwtCookie()

  return NextResponse.json({ success: true })
}
