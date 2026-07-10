export type OrganizationVisibility = "PUBLIC" | "PRIVATE"
export type FileType = "IMAGE" | "VIDEO" | "FILE"

export interface User {
  id: number
  name?: string
  picture?: string
}

export interface AuthResponse {
  token: string
  user: User
}

export interface ProfileResponse {
  name: string
  email?: string
  phone?: string
  university?: string
  user: User
}

export interface OrganizationResponse {
  id: number
  name: string
  slug: string
  description?: string
  image?: string
  visibility: OrganizationVisibility
  ownerName: string
}

export interface CourseResponse {
  id: number
  title: string
  slug: string
  description?: string
  coverUrl?: string
  status: "DRAFT" | "PUBLISHED"
  organizationName: string
}

export interface EnrollmentResponse {
  courseId: number
  courseTitle: string
  enrolledAt: string
}

export interface ChapterResponse {
  id: number
  title: string
  position?: number
  lessons: LessonResponse[]
}

export interface LessonResponse {
  id: number
  title: string
  position?: number
}

export interface BlockResponse {
  id: number
  title?: string
  content?: string
  position?: number
  question?: QuestionResponse
}

export interface BlockPublicResponse {
  id: number
  title?: string
  content?: string
  position?: number
  question?: QuestionPublicResponse
}

export interface QuestionResponse {
  id: number
  content: string
  options?: string[]
  correctAnswerIndex: number
}

export interface QuestionPublicResponse {
  id: number
  content: string
  options?: string[]
}

export interface QuizResponse {
  id?: number
  title?: string
  courseId?: number
  questions?: QuestionResponse[]
}

export interface PostResponse {
  id: number
  title: string
  content?: string
  author: AuthorResponse
  organizationId: number
  courseId: number
  likesCount: number
  commentsCount: number
  createdAt: string
}

export interface AuthorResponse {
  id: number
  name?: string
  picture?: string
}

export interface CommentResponse {
  id: number
  content: string
  author: AuthorResponse
  parentCommentId?: number
  createdAt: string
}

export interface CourseMediaResponse {
  id: number
  name: string
  url: string
  type: FileType
  courseId: number
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

export interface Page<T> {
  totalElements?: number
  totalPages?: number
  size?: number
  content?: T[]
  number?: number
  pageable?: PageableObject
  sort?: SortObject
  first?: boolean
  last?: boolean
  numberOfElements?: number
  empty?: boolean
}

export interface CourseDetailsResponse {
  id: number
  title: string
  slug: string
  description?: string
  coverUrl?: string
  organizationName: string
  chapters: ChapterResponse[]
  progress: CourseProgressResponse
}

export interface CourseProgressResponse {
  lastLessonId?: number
  lastBlockId?: number
  progressPercentage: number
  completed: boolean
  completedAt?: string
}

export interface PageCourseResponse {
  totalElements?: number
  totalPages?: number
  size?: number
  content?: CourseResponse[]
  number?: number
  pageable?: PageableObject
  sort?: SortObject
  numberOfElements?: number
  first?: boolean
  last?: boolean
  empty?: boolean
}

export interface SubmitBlockAnswerResponse {
  correct: boolean
  completed: boolean
  nextBlockId?: number
  nextLessonId?: number
  nextChapterId?: number
  courseCompleted: boolean
}

export type PagePostResponse = Page<PostResponse>
export type PageCourseMediaResponse = Page<CourseMediaResponse>
