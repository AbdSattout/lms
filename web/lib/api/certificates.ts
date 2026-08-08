import "server-only"

import { backend, type BackendFetchOptions } from "@/lib/api/backend"
import { defineApiRoute } from "@/lib/api/route"
import type { CertificateResponse } from "@/lib/api/types"

export const getByCode = defineApiRoute({
  get: (code: string, options?: BackendFetchOptions) =>
    backend<CertificateResponse>(`/certificates/${encodeURIComponent(code)}`, {
      method: "GET",
      requireAuth: false,
      ...options,
    }),
})
