import { NextRequest, NextResponse } from "next/server"

export function resolveSafeCallbackUrl(
  candidate: string | null | undefined,
  fallback = "/"
) {
  if (!candidate) {
    return fallback
  }

  // only allow relative paths
  if (!candidate.startsWith("/") || candidate.startsWith("//")) {
    return fallback
  }

  return candidate
}

export function readCallbackUrlFromRequest(request: NextRequest) {
  const callbackFromQuery = request.nextUrl.searchParams.get("callbackUrl")
  return resolveSafeCallbackUrl(callbackFromQuery)
}

export function buildLoginPath(callbackUrl = "/") {
  const safeCallbackUrl = resolveSafeCallbackUrl(callbackUrl)
  return `/login?callbackUrl=${encodeURIComponent(safeCallbackUrl)}` as const
}

export function buildLoginErrorPath(message: string, callbackUrl = "/") {
  const loginPath = buildLoginPath(callbackUrl)
  return `${loginPath}&error=${encodeURIComponent(message)}` as const
}

export function buildLoginRedirectResponse(request: NextRequest) {
  const callbackUrl = readCallbackUrlFromRequest(request)
  const loginPath = buildLoginPath(callbackUrl)
  return NextResponse.redirect(new URL(loginPath, request.url))
}
