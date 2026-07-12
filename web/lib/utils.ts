export { cn, type ClassValue } from "cnfast";

export function generateSlug(name: string, prefix = "org"): string | null {
  if (!name) return null
  if (!/^[a-zA-Z\s_]+$/.test(name)) return `${prefix}-${Date.now()}`
  return name
    .trim()
    .toLowerCase()
    .replace(/[\s_]+/g, "-")
}
