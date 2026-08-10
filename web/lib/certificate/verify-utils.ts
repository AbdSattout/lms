// Client-safe helpers for the certificate verification flow. No server-only
// imports here so these can be used from both server and client components.

export const CERTIFICATE_CODE_PATTERN = /^[A-Za-z0-9-]+$/

/**
 * Extracts a certificate code from either a raw code or a verify URL, e.g.
 *  - "ABC-123"
 *  - "/verify/ABC-123"
 *  - "https://example.com/verify/ABC-123?ref=x"
 *
 * Returns the normalized code or null when nothing valid is found.
 */
export function normalizeCertificateCode(value: string): string | null {
  const raw = value.trim()
  const urlMatch = raw.match(/\/verify\/([A-Za-z0-9-]+)(?:[/?#]|$)/)
  const candidate = urlMatch ? urlMatch[1] : raw
  return CERTIFICATE_CODE_PATTERN.test(candidate) ? candidate : null
}