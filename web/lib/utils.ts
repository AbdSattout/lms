import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function generateSlug(name: string): string | null {
  if (!name || !/^[a-zA-Z\s_]+$/.test(name)) return `org-${Date.now()}`
  return name
    .trim()
    .toLowerCase()
    .replace(/[\s_]+/g, "-")
}
