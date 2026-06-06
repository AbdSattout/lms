import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  const token = request.cookies.get("better-auth.session_token")?.value

  if (!token) {
    const loginUrl = new URL("/", request.url)

    loginUrl.searchParams.set("callbackUrl", request.nextUrl.pathname)

    return NextResponse.redirect(loginUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/organization/:path*"],
}
