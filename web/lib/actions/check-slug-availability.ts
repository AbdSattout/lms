"use server"

import { api } from "@/lib/api"
import { slugSchema } from "@/lib/validation"

export async function checkSlugAvailability(slug: string) {
  if (!slug || !slugSchema.safeParse(slug).success) {
    return false
  }
  return api.organizations.checkSlugAvailability(slug)
}
