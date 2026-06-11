import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function generateSlug(name: string, prefix = "org"): string | null {
  if (!name) return null
  if (!/^[a-zA-Z\s_]+$/.test(name)) return `${prefix}-${Date.now()}`
  return name
    .trim()
    .toLowerCase()
    .replace(/[\s_]+/g, "-")
}
