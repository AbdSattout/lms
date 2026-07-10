export type OrganizationVisibility = "PUBLIC" | "PRIVATE"
export type FileType = "IMAGE" | "VIDEO" | "FILE"

export interface User {
  id?: number
  name?: string
  picture?: string
}

export interface UpdateUserRequest {
  name?: string
}

export interface AuthResponse {
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
  user?: User
}

export interface UpdateProfile {
  email?: string
  phone?: string
  university?: string
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
  slug: string
  description?: string
}

export interface UpdateCourseRequest {
  title?: string
  slug?: string
  description?: string
}

export interface CourseResponse {
  id?: number
  title?: string
  slug?: string
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
  lessons?: LessonResponse[]
}

export interface ReorderChaptersRequest {
  chapterIds: number[]
}

export interface CreateLessonRequest {
  title: string
}

export interface UpdateLessonRequest {
  title?: string
  isPublished?: boolean
}

export interface LessonResponse {
  id?: number
  title?: string
  position?: number
  isPublished?: boolean
}

export interface ReorderLessonsRequest {
  lessonIds: number[]
}

export interface CreateBlockRequest {
  title: string
  content?: string
  question?: CreateQuestionRequest
}

export interface UpdateBlockRequest {
  title?: string
  content?: string
  question?: UpdateQuestionRequest
}

export interface BlockResponse {
  id?: number
  title?: string
  content?: string
  position?: number
  question?: QuestionResponse
}

export interface BlockPublicResponse {
  id?: number
  title?: string
  content?: string
  position?: number
  question?: QuestionPublicResponse
}

export interface ReorderBlocksRequest {
  blockIds: number[]
}

export interface CreateQuestionRequest {
  content: string
  options: string[]
  correctAnswerIndex: number
}

export interface QuestionResponse {
  id?: number
  content?: string
  options?: string[]
  correctAnswerIndex?: number
}

export interface QuestionPublicResponse {
  id?: number
  content?: string
  options?: string[]
}

export interface CreatePostRequest {
  title: string
  content: string
  courseId: number
}

export interface UpdatePostRequest {
  title?: string
  content?: string
}

export interface PostResponse {
  id: number
  title?: string
  content?: string
  author?: AuthorResponse
  organizationId?: number
  courseId: number
  likesCount?: number
  commentsCount?: number
  createdAt?: string
}

export interface AuthorResponse {
  id: number
  name?: string
  picture?: string
}

export interface CreateCommentRequest {
  content: string
  parentCommentId?: number
}

export interface CommentResponse {
  id: number
  content?: string
  author?: AuthorResponse
  parentCommentId?: number
  createdAt?: string
}

export interface CourseMediaResponse {
  id?: number
  name?: string
  url?: string
  type?: FileType
  courseId?: number
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
  id?: number
  title?: string
  slug?: string
  description?: string
  coverUrl?: string
  organizationName?: string
  chapters?: ChapterResponse[]
  progress?: CourseProgressResponse
}

export interface CourseProgressResponse {
  lastLessonId?: number
  lastBlockId?: number
  progressPercentage?: number
  completed?: boolean
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

export interface SubmitBlockAnswerRequest {
  answerIndex: number
}

export interface SubmitBlockAnswerResponse {
  correct?: boolean
  completed?: boolean
  nextBlockId?: number
  nextLessonId?: number
  nextChapterId?: number
  courseCompleted?: boolean
}

export interface UpdateQuestionRequest {
  content?: string
  options?: string[]
  correctAnswerIndex?: number
}

export type PagePostResponse = Page<PostResponse>
export type PageCourseMediaResponse = Page<CourseMediaResponse>
