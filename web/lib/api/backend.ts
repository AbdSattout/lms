import "server-only"

import { redirect } from "next/navigation"

import {
  getAdminJwtFromCookies,
  getBackendJwtFromCookies,
} from "@/lib/auth/backend-jwt-cookie"
import { buildLoginPath } from "@/lib/auth/callback-url"

type UnauthorizedBehavior = "throw" | "redirect"

export interface BackendFetchOptions extends Omit<
  RequestInit,
  "body" | "headers"
> {
  requireAuth?: boolean
  onUnauthorized?: UnauthorizedBehavior
  callbackUrl?: string
  headers?: HeadersInit
  body?: unknown
  timeoutMs?: number
}

export class BackendError extends Error {
  readonly status: number
  readonly code?: string

  constructor(status: number, message: string, code?: string) {
    super(message)
    this.name = "BackendError"
    this.status = status
    this.code = code
  }
}

export class BackendUnauthorizedError extends BackendError {
  constructor(message = "Backend authentication required.") {
    super(401, message)
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
    timeoutMs = 30_000,
    ...init
  } = options

  const requestHeaders = new Headers(headers)

  if (requireAuth) {
    const token = await getJwtForPath(path)

    if (!token) {
      handleUnauthorized(unauthorized, callbackUrl)
    }

    requestHeaders.set("authorization", `Bearer ${token}`)
  }

  const hasBody = body !== undefined
  const isFormData = body instanceof FormData

  if (hasBody && !isFormData && !requestHeaders.has("content-type")) {
    requestHeaders.set("content-type", "application/json")
  }

  const timeoutSignal = AbortSignal.timeout(timeoutMs)

  let response: Response

  try {
    response = await fetch(buildBackendUrl(path), {
      ...init,
      signal: init.signal
        ? AbortSignal.any([init.signal, timeoutSignal])
        : timeoutSignal,
      cache,
      headers: requestHeaders,
      body: !hasBody ? undefined : isFormData ? body : JSON.stringify(body),
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === "TimeoutError") {
      throw new Error(
        "Backend request failed (504): The backend took too long to respond."
      )
    }

    throw error
  }

  if (response.status === 401 && requireAuth) {
    handleUnauthorized(unauthorized, callbackUrl)
  }

  if (!response.ok) {
    const details = await readResponseDetails(response)
    console.error("[Backend Error]", {
      url: buildBackendUrl(path),
      method: init.method ?? "GET",
      status: response.status,
      statusText: response.statusText,
      details: details.message,
    })
    throw new BackendError(
      response.status,
      `Backend request failed (${response.status}): ${details.message}`,
      details.code
    )
  }

  if (response.status === 204) {
    return undefined as T
  }

  const contentType = response.headers.get("content-type")

  if (contentType?.includes("application/json")) {
    return response.json() as Promise<T>
  }

  const text = await response.text()
  return (text.length > 0 ? text : undefined) as T
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

async function getJwtForPath(path: string) {
  if (path.startsWith("/admin/")) {
    return getAdminJwtFromCookies()
  }

  return getBackendJwtFromCookies()
}

async function readResponseDetails(response: Response) {
  try {
    const body = await response.json()
    const code = typeof body?.code === "string" ? body.code : undefined
    return { message: JSON.stringify(body), code }
  } catch {
    return { message: await response.text() }
  }
}
