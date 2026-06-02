export type OrganizationVisibility = "PUBLIC" | "PRIVATE"

export interface User {
  id?: number
  name?: string
  picture?: string
}

export interface AuthLoginResponse {
  token?: string
  user?: User
}

export interface CreateProfileRequest {
  email?: string
  phone?: string
  university?: string
}

export interface ProfileResponse {
  name?: string
  email?: string
  phone?: string
  university?: string
}

export interface UpdateProfile {
  email?: string
  phone?: string
  university?: string
}

export interface UpdateUserRequest {
  name?: string
}

export interface CreateOrganizationRequest {
  name: string
  slug: string
  description?: string
  visibility?: OrganizationVisibility
}

export interface UpdateOrganizationRequest {
  name?: string
  slug?: string
  description?: string
  visibility?: OrganizationVisibility
}

export interface OrganizationResponse {
  id?: number
  name?: string
  slug?: string
  description?: string
  image?: string
  visibility?: OrganizationVisibility
  ownerName?: string
}

export interface CreateCourseRequest {
  title: string
  description?: string
  coverUrl?: string
}

export interface UpdateCourseRequest {
  title?: string
  description?: string
}

export interface CourseResponse {
  id?: number
  title?: string
  description?: string
  coverUrl?: string
  organizationName?: string
}

export interface EnrollmentResponse {
  courseId?: number
  courseTitle?: string
  enrolledAt?: string
}

export interface CreateChapterRequest {
  title: string
}

export interface UpdateChapterRequest {
  title: string
}

export interface ChapterResponse {
  id?: number
  title?: string
  position?: number
}

export interface ReorderChaptersRequest {
  chapterIds: number[]
}

export interface Pageable {
  page?: number
  size?: number
  sort?: string[]
}

export interface PageableObject {
  offset?: number
  paged?: boolean
  pageNumber?: number
  pageSize?: number
  sort?: SortObject
  unpaged?: boolean
}

export interface SortObject {
  empty?: boolean
  sorted?: boolean
  unsorted?: boolean
}

export interface PageCourseResponse {
  totalElements?: number
  totalPages?: number
  size?: number
  content?: CourseResponse[]
  number?: number
  pageable?: PageableObject
  sort?: SortObject
  first?: boolean
  last?: boolean
  numberOfElements?: number
  empty?: boolean
}
