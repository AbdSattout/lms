import { NextRequest, NextResponse } from "next/server"

import { api } from "@/lib/api"
import { BackendError } from "@/lib/api/backend"
import {
  clearAdminJwtCookie,
  clearBackendJwtCookie,
  setAdminJwtCookie,
} from "@/lib/auth/backend-jwt-cookie"

export async function POST(request: NextRequest) {
  console.log("\n====== طلب دخول جديد למشرف ======")

  const textBody = await request.text().catch(() => "")
  console.log("Raw Frontend Body received:", textBody)

  const body = textBody ? JSON.parse(textBody) : null
  const email = typeof body?.email === "string" ? body.email.trim() : ""
  const password = typeof body?.password === "string" ? body.password : ""

  if (!email || !password) {
    return NextResponse.json(
      { message: "البريد الإلكتروني وكلمة المرور مطلوبان." },
      { status: 400 }
    )
  }

  try {
    console.log("جاري طلب الواجهة الخلفية (Backend) لمعلومات:", {
      email,
      password: "...",
    })

    const backendSession = await api.auth.loginAdmin.post(email, password)

    console.log("✅ نجح الباك اند, النتيجة: ", backendSession)

    if (!backendSession.token) {
      throw new Error("رد الخادم لم يحتوي على توكن (token) مصادقة.")
    }

    await setAdminJwtCookie(backendSession.token)
    await clearBackendJwtCookie()

    return NextResponse.json(
      {
        success: true,
        isAdmin: true,
      },
      { headers: { "Cache-Control": "no-store" } }
    )
  } catch (error) {
    console.error("❌ فشل تسجيل دخول المشرف في السيرفر:")

    if (error instanceof BackendError) {
      console.error("حالة الخطأ Backend Error Status:", error.status)
      console.error(
        "جسم الرد أو رسالة السيرفر Backend Msg:",
        error.message || error
      )
    } else {
      console.error("استثناء مجهول غير مُعالج:", error)
    }

    await clearAdminJwtCookie()

    const status = error instanceof BackendError ? error.status : 502

    return NextResponse.json(
      {
        message:
          error instanceof BackendError && error.status === 401
            ? "بيانات المشرف غير صحيحة"
            : "حدث خطأ ما، حاول مرة أخرى.",
      },
      { status }
    )
  }
}
