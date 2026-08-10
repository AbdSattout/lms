import "server-only"

import { unstable_cache } from "next/cache"

import { BackendError } from "@/lib/api/backend"
import { getByCode } from "@/lib/api/certificates"

export const CERTIFICATE_TAG = "certificate"

// Certificate codes are user-facing slugs passed through URLs, so only allow
// a tight character set (no slashes, path separators, or control chars).
export const SAFE_CODE_PATTERN = /^[A-Za-z0-9-]+$/

export function isCertificateNotFound(err: unknown) {
  return (
    err instanceof BackendError &&
    // 404: not found. 400: the backend reports unknown/invalid codes.
    (err.status === 404 || err.status === 400)
  )
}

/**
 * Certificate lookup, cached in Next's durable Data Cache (immutable docs,
 * so they only need to be fetched from the backend once). Errors are not
 * cached — a temporary backend failure won't poison the cache.
 */
export const getCertificate = unstable_cache(
  (code: string) => getByCode(code),
  ["certificate-by-code"],
  { tags: [CERTIFICATE_TAG] }
)
