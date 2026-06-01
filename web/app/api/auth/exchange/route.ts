import { NextRequest, NextResponse } from "next/server"

import { api } from "@/lib/api"
import {
  clearBackendJwtCookie,
  setBackendJwtCookie,
} from "@/lib/auth/backend-jwt-cookie"
import {
  buildLoginRedirectResponse,
  readCallbackUrlFromRequest,
} from "@/lib/auth/callback-url"
import { getBetterAuthSession, getOidcIdToken } from "@/lib/auth/session"

async function exchangeBackendSession() {
  const betterAuthSession = await getBetterAuthSession()

  if (!betterAuthSession) {
    return { redirectToLogin: true as const }
  }

  const idToken = await getOidcIdToken()

  if (!idToken) {
    return {
      redirectToLogin: false as const,
      errorStatus: 400,
      message: "idToken is missing.",
    }
  }

  try {
    const backendSession = await api.auth.login.post(idToken)
    await setBackendJwtCookie(backendSession.token)

    return {
      redirectToLogin: false as const,
      user: backendSession.user,
    }
  } catch (error) {
    await clearBackendJwtCookie()

    const message = error instanceof Error ? error.message : "Unexpected error."

    return {
      redirectToLogin: false as const,
      errorStatus: 502,
      message,
    }
  }
}

export async function GET(request: NextRequest) {
  const result = await exchangeBackendSession()

  if (result.redirectToLogin || result.message === "NEXT_REDIRECT") {
    return buildLoginRedirectResponse(request)
  }

  if ("errorStatus" in result) {
    return NextResponse.json(
      { message: result.message },
      { status: result.errorStatus }
    )
  }

  const callbackUrl = readCallbackUrlFromRequest(request)
  return NextResponse.redirect(new URL(callbackUrl, request.url))
}
