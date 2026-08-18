"use server"

import { comments, organizations, reports, users } from "@/lib/api/admin"

import type {
  ReportResponse,
  ReportReviewRequest,
  ReportStatus,
} from "@/lib/api/types"

import type { PageableInput } from "@/lib/validation"

export async function getAdminReportsAction(pageable: PageableInput) {
  return reports.list.get(pageable)
}

export async function getAdminReportsByStatusAction(
  status: ReportStatus,
  pageable: PageableInput
) {
  return reports.byStatus.get(status, pageable)
}

export async function reviewAdminReportAction(
  reportId: number,
  request: ReportReviewRequest
): Promise<ReportResponse> {
  return reports.review.patch(reportId, request)
}

export async function getAdminOrganizationAction(organizationId: number) {
  return organizations.get(organizationId)
}

export async function getAdminOrganizationCoursesAction(
  organizationId: number,
  pageable: PageableInput
) {
  return organizations.courses.get(organizationId, pageable)
}

export async function getAdminOrganizationPostAction(
  organizationId: number,
  postId: number
) {
  return organizations.post.get(organizationId, postId)
}
export async function getAdminOrganizationPostsAction(
  organizationId: number,
  pageable: PageableInput
) {
  return organizations.posts.get(organizationId, pageable)
}
export async function getAdminCommentAction(commentId: number) {
  return comments.get(commentId)
}

export async function getAdminUserPostsAction(
  userId: number,
  pageable: PageableInput
) {
  return users.posts.get(userId, pageable)
}

export async function getAdminUserCommentsAction(
  userId: number,
  pageable: PageableInput
) {
  return users.comments.get(userId, pageable)
}
