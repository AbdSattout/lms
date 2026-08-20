import { NextResponse } from "next/server"

import {
  clearAdminJwtCookie,
  clearBackendJwtCookie,
} from "@/lib/auth/backend-jwt-cookie"

export async function POST() {
  await clearBackendJwtCookie()
  await clearAdminJwtCookie()

  return NextResponse.json({ success: true })
}
