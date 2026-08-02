export const MAX_IMAGE_SIZE = 1024 * 1024

export function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)}MB`
  return `${Math.max(1, Math.round(bytes / 1024))}KB`
}

export function getImageUploadError(file: File | null | undefined): string | null {
  if (!file || file.size === 0) return null
  if (!file.type.startsWith("image/")) return "يجب أن يكون الملف صورة"
  if (file.size > MAX_IMAGE_SIZE) {
    return `حجم الصورة يتجاوز الحد الأقصى (${formatBytes(MAX_IMAGE_SIZE)})`
  }
  return null
}
