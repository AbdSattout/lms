import { NextRequest, NextResponse } from "next/server"

import { api } from "@/lib/api"
import { BackendError } from "@/lib/api/backend"

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => null)
  const email = typeof body?.email === "string" ? body.email.trim() : ""

  if (!email) {
    return NextResponse.json(
      { message: "حدث خطأ ما، حاول مرة أخرى." },
      { status: 400 }
    )
  }

  try {
    await api.auth.requestEmailOtp.post(email)

    return NextResponse.json({ success: true })
  } catch (error) {
    const cooldown =
      error instanceof BackendError && /recently|sent/i.test(error.message)
    const status = cooldown
      ? 429
      : error instanceof BackendError
        ? error.status
        : 502

    return NextResponse.json(
      { message: "حدث خطأ ما، حاول مرة أخرى." },
      { status }
    )
  }
}
