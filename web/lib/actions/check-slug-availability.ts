"use server"

import { api } from "@/lib/api"

export async function checkSlugAvailability(slug: string) {
  return api.organizations.checkSlugAvailability(slug)
}
