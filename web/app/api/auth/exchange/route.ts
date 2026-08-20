import { NextRequest, NextResponse } from "next/server"

import { api } from "@/lib/api"
import { BackendError } from "@/lib/api/backend"
import {
  clearAdminJwtCookie,
  clearBackendJwtCookie,
  setBackendJwtCookie,
} from "@/lib/auth/backend-jwt-cookie"
import {
  buildLoginErrorPath,
  buildLoginRedirectResponse,
  readCallbackUrlFromRequest,
} from "@/lib/auth/callback-url"
import { getBetterAuthSession, getOidcIdToken } from "@/lib/auth/session"
import {
  isUserBannedError,
  USER_BANNED_MESSAGE,
} from "@/lib/auth/user-banned"

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
    await clearBackendJwtCookie()
    await clearAdminJwtCookie()

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
    await clearAdminJwtCookie()

    return {
      redirectToLogin: false as const,
      user: backendSession.user,
    }
  } catch (error) {
    await clearBackendJwtCookie()
    await clearAdminJwtCookie()

    const isBanned = isUserBannedError(error)

    return {
      redirectToLogin: false as const,
      errorStatus: error instanceof BackendError ? error.status : 502,
      message: isBanned
        ? USER_BANNED_MESSAGE
        : "حدث خطأ ما، حاول مرة أخرى.",
    }
  }
}

export async function GET(request: NextRequest) {
  const providerParam = request.nextUrl.searchParams.get("provider")
  const provider: LoginProvider =
    providerParam === "google" ? "google" : "telegram"
  const result = await exchangeBackendSession(provider)

  if (result.redirectToLogin) {
    return buildLoginRedirectResponse(request)
  }

  if ("errorStatus" in result) {
    const callbackUrl = readCallbackUrlFromRequest(request)
    const errorPath = buildLoginErrorPath(
      result.message ?? "حدث خطأ ما، حاول مرة أخرى.",
      callbackUrl
    )
    return NextResponse.redirect(new URL(errorPath, request.url))
  }

  const callbackUrl = readCallbackUrlFromRequest(request)
  return NextResponse.redirect(new URL(callbackUrl, request.url))
}
