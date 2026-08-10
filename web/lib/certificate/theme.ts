export const theme = {
  background: "#ffffff",
  foreground: "#09090b",
  primary: "#007593",
  primaryForeground: "#ecfeff",
  border: "#e4e4e7",
  muted: "#71717b",
} as const

export const gradeLabels: Record<
  "BASIC" | "GOOD" | "VERY_GOOD" | "EXCELLENT",
  string
> = {
  BASIC: "مقبول",
  GOOD: "جيد",
  VERY_GOOD: "جيد جدًا",
  EXCELLENT: "ممتاز",
}
