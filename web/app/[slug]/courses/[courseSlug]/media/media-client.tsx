"use client"

import { MediaLibrary } from "@/components/media-library"
import { CourseResponse } from "@/lib/api/types"

interface CourseMediaClientProps {
  course: CourseResponse
  orgSlug: string
}

export function CourseMediaClient({ orgSlug, course }: CourseMediaClientProps) {
  return (
    <MediaLibrary
      title={`وسائط ${course.title}`}
      orgSlug={orgSlug}
      course={course}
      organizationId={course.organization.id}
    />
  )
}
