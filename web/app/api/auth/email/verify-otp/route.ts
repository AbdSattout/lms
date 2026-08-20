import { NextRequest, NextResponse } from "next/server"

import { api } from "@/lib/api"
import { BackendError } from "@/lib/api/backend"
import {
  clearAdminJwtCookie,
  clearBackendJwtCookie,
  setBackendJwtCookie,
} from "@/lib/auth/backend-jwt-cookie"

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => null)
  const email = typeof body?.email === "string" ? body.email.trim() : ""
  const code = typeof body?.code === "string" ? body.code.trim() : ""

  if (!email || !code) {
    return NextResponse.json(
      { message: "حدث خطأ ما، حاول مرة أخرى." },
      { status: 400 }
    )
  }

  try {
    const backendSession = await api.auth.loginWithEmailOtp.post(email, code)

    if (!backendSession.token) {
      throw new Error("Backend login response missing token.")
    }

    await setBackendJwtCookie(backendSession.token)
    await clearAdminJwtCookie()
  } catch (error) {
    await clearBackendJwtCookie()
    await clearAdminJwtCookie()

    const status = error instanceof BackendError ? error.status : 502

    return NextResponse.json(
      { message: "حدث خطأ ما، حاول مرة أخرى." },
      { status }
    )
  }

  return NextResponse.json(
    { success: true },
    { headers: { "Cache-Control": "no-store" } }
  )
}
