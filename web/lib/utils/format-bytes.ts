export function formatBytes(bytes: number): string {
  if (bytes === 0) return "0 بايت"

  const k = 1024
  const sizes = ["بايت", "كيلوبايت", "ميجابايت", "جيجابايت", "تيرابايت"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
}
