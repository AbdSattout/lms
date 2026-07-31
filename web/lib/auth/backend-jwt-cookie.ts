import "server-only"

import { cookies } from "next/headers"

export const BACKEND_JWT_COOKIE_NAME = "backend_jwt"

const isProduction = process.env.NODE_ENV === "production"

const backendJwtCookieOptions = {
  httpOnly: true,
  sameSite: "lax" as const,
  secure: isProduction,
  path: "/",
  maxAge: 7 * 24 * 60 * 60,
}

export async function setBackendJwtCookie(token: string) {
  const cookieStore = await cookies()
  cookieStore.set(BACKEND_JWT_COOKIE_NAME, token, backendJwtCookieOptions)
}

export async function clearBackendJwtCookie() {
  const cookieStore = await cookies()
  cookieStore.set(BACKEND_JWT_COOKIE_NAME, "", {
    ...backendJwtCookieOptions,
    maxAge: 0,
  })
}

export async function getBackendJwtFromCookies() {
  const cookieStore = await cookies()
  return cookieStore.get(BACKEND_JWT_COOKIE_NAME)?.value ?? null
}
