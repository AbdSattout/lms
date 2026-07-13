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
  courseId: number
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
  id: number
  title: string
  courseId: number
  questions: QuestionResponse[]
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

export interface ChapterDetailsResponse {
  id: number
  title: string
  position?: number
  courseId: number
  organizationId: number
}

export interface LessonDetailsResponse {
  id: number
  title: string
  position?: number
  chapterId: number
  courseId: number
  organizationId: number
}

export interface GenerateQuestionFromBlockContentRequest {
  blockContent: string
}

export interface GeneratedQuestionResponse {
  content: string
  options: string[]
  correctAnswerIndex: number
}

export interface GenerateAiTextRequest {
  text: string
  action: AiTextAction
  tone?: AiTextTone
}

export interface GeneratedAiTextResponse {
  action: AiTextAction
  tone?: AiTextTone
  result: string
}

export type AiTextAction =
  | "PROOFREAD"
  | "REWRITE"
  | "SUMMARIZE"
  | "EXPAND"
  | "CHANGE_TONE"
  | "WRITE"

export type AiTextTone =
  | "PROFESSIONAL"
  | "FRIENDLY"
  | "SIMPLE"
  | "ACADEMIC"
  | "MOTIVATIONAL"

export type PagePostResponse = Page<PostResponse>
export type PageCourseMediaResponse = Page<CourseMediaResponse>

export type Role = "OWNER" | "ADMIN" | "STUDENT"
export type InviteStatus =
  | "PENDING"
  | "ACCEPTED"
  | "DECLINED"
  | "EXPIRED"
  | "CANCELLED"
export type JoinRequestStatus =
  | "PENDING"
  | "ACCEPTED"
  | "REJECTED"
  | "CANCELLED"

export interface OrganizationInviteResponse {
  id: number
  userId: number
  userName: string
  role: Role
  status: InviteStatus
  invitedByName: string
  expiresAt: string
  createdAt: string
  maxUses: number
  usedCount: number
}

export interface CreateInviteRequest {
  userId: number
  role?: Role
}

export interface CreatePublicInviteRequest {
  role?: Role
  maxUses?: number
}

export interface UpdateInviteCapacityRequest {
  maxUses?: number
}

export interface OrganizationMemberResponse {
  memberId: number
  user: UserResponse
  role: Role
}

export interface UserResponse {
  id: number
  name: string
  picture: string
}

export interface JoinRequestResponse {
  id: number
  status: JoinRequestStatus
  createdAt: string
  user: UserResponse
}

export interface UserSearchResponse {
  id: number
  name: string
  picture: string
  email: string
}

export interface FinalQuizResponse {
  quizId: number
  courseId: number
  questions: QuestionPublicResponse[]
}

export interface SubmitFinalQuizAnswer {
  questionId: number
  answerIndex: number
}

export interface FinalQuizQuestionResultResponse {
  questionId: number
  content: string
  options: string[]
  selectedAnswerIndex: number
  correctAnswerIndex: number
  correct: boolean
}

export interface FinalQuizSubmitResponse {
  attemptId: number
  score: number
  total: number
  results: FinalQuizQuestionResultResponse[]
}

export type PageOrganizationMemberResponse = Page<OrganizationMemberResponse>
