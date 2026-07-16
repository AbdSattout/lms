"use client"

import { MediaLibrary } from "@/components/media-library"

interface OrgMediaClientProps {
  slug: string
}

export function OrgMediaClient({ slug }: OrgMediaClientProps) {
  return (
    <MediaLibrary
      title="مكتبة الوسائط"
      orgSlug={slug}
    />
  )
}
