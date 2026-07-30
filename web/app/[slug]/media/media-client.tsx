"use client"

import { MediaLibrary } from "@/components/media-library"

interface OrgMediaClientProps {
  slug: string
  organizationId: number
}

export function OrgMediaClient({ slug, organizationId }: OrgMediaClientProps) {
  return (
    <MediaLibrary
      title="مكتبة الوسائط"
      orgSlug={slug}
      organizationId={organizationId}
    />
  )
}
