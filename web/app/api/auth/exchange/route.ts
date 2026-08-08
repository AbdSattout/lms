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

const loginByProvider = {
  telegram: api.auth.loginWithTelegram,
  google: api.auth.loginWithGoogle,
} as const

export type LoginProvider = keyof typeof loginByProvider

async function exchangeBackendSession(provider: LoginProvider) {
  const betterAuthSession = await getBetterAuthSession()

  if (!betterAuthSession) {
    return { redirectToLogin: true as const }
  }

  const idToken = await getOidcIdToken(provider)

  if (!idToken) {
    return {
      redirectToLogin: false as const,
      errorStatus: 400,
      message: "idToken is missing.",
    }
  }

  try {
    const backendSession = await loginByProvider[provider].post(idToken)
    if (!backendSession.token) {
      throw new Error("Backend login response missing token.")
    }

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
  const providerParam = request.nextUrl.searchParams.get("provider")
  const provider: LoginProvider = providerParam === "google" ? "google" : "telegram"
  const result = await exchangeBackendSession(provider)

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
