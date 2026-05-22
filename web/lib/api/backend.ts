import "server-only"

import { redirect } from "next/navigation"

import {
  clearBackendJwtCookie,
  getBackendJwtFromCookies,
} from "@/lib/auth/backend-jwt-cookie"
import { buildLoginPath } from "@/lib/auth/callback-url"

type UnauthorizedBehavior = "throw" | "redirect"

type JsonBody =
  | Record<string, unknown>
  | unknown[]
  | string
  | number
  | boolean
  | null

export interface BackendFetchOptions extends Omit<
  RequestInit,
  "body" | "headers"
> {
  requireAuth?: boolean
  onUnauthorized?: UnauthorizedBehavior
  callbackUrl?: string
  headers?: HeadersInit
  body?: JsonBody
}

export class BackendUnauthorizedError extends Error {
  constructor() {
    super("Backend authentication required.")
    this.name = "BackendUnauthorizedError"
  }
}

const backendBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL

function getBackendBaseUrl() {
  if (!backendBaseUrl) {
    throw new Error("Missing NEXT_PUBLIC_API_BASE_URL.")
  }

  return backendBaseUrl
}

function buildBackendUrl(path: string) {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`
  return new URL(normalizedPath, getBackendBaseUrl()).toString()
}

/**
 * Makes a fetch request to the backend API.
 * @param path The path to the backend API endpoint.
 * @param options The fetch options.
 * @returns The parsed response body.
 */
export async function backend<T>(
  path: string,
  options: BackendFetchOptions = {}
): Promise<T> {
  const {
    requireAuth = true,
    onUnauthorized: unauthorized = "redirect",
    callbackUrl,
    headers,
    body,
    cache = "no-store",
    ...init
  } = options

  const requestHeaders = new Headers(headers)

  if (requireAuth) {
    const token = await getBackendJwtFromCookies()

    if (!token) {
      handleUnauthorized(unauthorized, callbackUrl)
    }

    requestHeaders.set("authorization", `Bearer ${token}`)
  }

  const hasJsonBody = body !== undefined

  if (hasJsonBody && !requestHeaders.has("content-type")) {
    requestHeaders.set("content-type", "application/json")
  }

  const response = await fetch(buildBackendUrl(path), {
    ...init,
    cache,
    headers: requestHeaders,
    body: hasJsonBody ? JSON.stringify(body) : undefined,
  })

  if (response.status === 401) {
    await clearBackendJwtCookie()
    handleUnauthorized(unauthorized, callbackUrl)
  }

  if (!response.ok) {
    let details: unknown

    try {
      details = await response.json()
    } catch {
      details = await response.text()
    }

    throw new Error(`Backend request failed (${response.status}): ${details}`)
  }

  if (response.status === 204) {
    return undefined as T
  }

  return response.json() as Promise<T>
}

function handleUnauthorized(
  behavior: UnauthorizedBehavior,
  callbackUrl?: string
): never {
  if (behavior === "redirect") {
    redirect(buildLoginPath(callbackUrl))
  }

  throw new BackendUnauthorizedError()
}
