export interface BaseEntityResponse {
  createdAt: string
  updatedAt: string
}

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

export type OrganizationVisibility = "PUBLIC" | "PRIVATE"

export interface OrganizationResponse {
  id: number
  name: string
  slug: string
  description?: string
  image?: string
  visibility: OrganizationVisibility
  ownerName: string
  baseEntity?: BaseEntityResponse
}

export type CourseStatus = "DRAFT" | "PUBLISHED"
export type EnrollmentStatus = "ACTIVE" | "COMPLETED" | "DROPPED"

export interface CourseEnrollmentResponse {
  id: number
  courseId: number
  courseTitle: string
  enrolledAt: string
  status: EnrollmentStatus
  placementTestCompleted?: boolean
  progressPercentage?: number
  currentChapterId?: number
  currentLessonId?: number
  currentBlockId?: number
  completedAt?: string
}

export interface CourseResponse {
  id: number
  title: string
  slug: string
  description?: string
  coverUrl?: string
  status: CourseStatus
  organizationName: string
  enrollment?: CourseEnrollmentResponse
  baseEntity?: BaseEntityResponse
}

export interface EnrollmentResponse {
  courseId?: number | null
  courseTitle: string
  enrolledAt: string
  rewards?: GamificationAwardResponse[]
}

export interface ChapterResponse {
  id: number
  title: string
  position?: number
  lessons: LessonResponse[]
  baseEntity?: BaseEntityResponse
}

export interface LessonResponse {
  id: number
  title: string
  position?: number
  baseEntity?: BaseEntityResponse
}

export interface BlockResponse {
  id: number
  title?: string
  content?: string
  position?: number
  question?: QuestionResponse
  baseEntity?: BaseEntityResponse
}

export interface BlockPublicResponse {
  id: number
  title?: string
  content?: string
  position?: number
  question?: QuestionPublicResponse
  baseEntity?: BaseEntityResponse
}

export type QuestionDifficulty = "EASY" | "MEDIUM" | "HARD"

export interface QuestionResponse {
  id: number
  courseId?: number | null
  content: string
  options: string[]
  correctAnswerIndex: number
  difficulty: QuestionDifficulty
  baseEntity?: BaseEntityResponse
}

export interface QuestionPublicResponse {
  id: number
  content: string
  options: string[]
  baseEntity?: BaseEntityResponse
}

export interface QuizResponse {
  id: number
  title: string
  courseId?: number | null
  difficulty: QuestionDifficulty
  questions: QuestionResponse[]
  baseEntity?: BaseEntityResponse
}

export interface PostResponse {
  id: number
  title: string
  content?: string
  author: AuthorResponse
  organizationId: number
  courseId?: number | null
  likeCount: number
  commentCount: number
  baseEntity?: BaseEntityResponse
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
  baseEntity?: BaseEntityResponse
}

export type FileType = "IMAGE" | "VIDEO" | "FILE"

export interface CourseMediaResponse {
  id: number
  name: string
  url: string
  type: FileType
  courseId?: number | null
  organizationMediaId?: number
  sizeBytes?: number
  baseEntity?: BaseEntityResponse
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
  courseId?: number | null
  organizationId: number
  baseEntity?: BaseEntityResponse
}

export interface LessonDetailsResponse {
  id: number
  title: string
  position?: number
  chapterId: number
  courseId?: number | null
  organizationId: number
  baseEntity?: BaseEntityResponse
}

export interface GenerateQuestionFromBlockContentRequest {
  blockContent: string
}

export interface GeneratedQuestionResponse {
  content: string
  options: string[]
  correctAnswerIndex: number
}

export type AiTextAction =
  | "PROOFREAD"
  | "REWRITE"
  | "SUMMARIZE"
  | "EXPAND"
  | "FORMAT_EQUATION"
  | "CHANGE_TONE"
  | "WRITE"

export type AiTextTone =
  | "PROFESSIONAL"
  | "FRIENDLY"
  | "SIMPLE"
  | "ACADEMIC"
  | "MOTIVATIONAL"

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

export interface GamificationAwardResponse {
  eventType: string
  referenceId: number
  awarded: boolean
  xpAwarded: number
  totalXp: number
  previousLevelNumber: number
  currentLevelNumber: number
  currentLevelTitle: string
  leveledUp: boolean
  baseEntity?: BaseEntityResponse
}
export interface StorageResponse {
  usedBytes: number
  availableBytes?: number
  totalBytes?: number
  usagePercentage?: number
  unlimited: boolean
}

export interface OrganizationOverviewResponse {
  owner: UserResponse & { username?: string }
  membersCount: number
  adminsCount: number
  studentsCount: number
  coursesCount: number
  publishedCoursesCount: number
  draftCoursesCount: number
  postsCount: number
  roadmapsCount: number
  storage: StorageResponse
}
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
  baseEntity?: BaseEntityResponse
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

export interface PostMediaResponse {
  id: number
  name: string
  url: string
  type: FileType
  organizationId: number
  organizationMediaId?: number
  sizeBytes?: number
  baseEntity?: BaseEntityResponse
}

export interface OrganizationMediaResponse {
  id: number
  name: string
  url: string
  type: FileType
  sizeBytes?: number
  organizationId: number
  baseEntity?: BaseEntityResponse
}

export interface OrganizationMediaSummaryResponse {
  organizationId: number
  totalFiles: number
  totalSizeBytes: number
}

export interface FinalQuizResponse {
  quizId: number
  courseId?: number | null
  difficulty?: QuestionDifficulty
  questions: QuestionPublicResponse[]
  baseEntity?: BaseEntityResponse
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
  rewards?: GamificationAwardResponse[]
  baseEntity?: BaseEntityResponse
}

export type PageOrganizationMemberResponse = Page<OrganizationMemberResponse>

export interface CreatePracticeQuizRequest {
  title: string
  description?: string
  questionIds: number[]
}

export interface PracticeQuizResponse {
  id: number
  title: string
  description?: string
  courseId?: number | null
  difficulty: QuestionDifficulty
  questions: QuestionResponse[]
  baseEntity?: BaseEntityResponse
}

export interface PracticeQuizSummaryResponse {
  id: number
  title: string
  description?: string
  courseId?: number | null
  difficulty: QuestionDifficulty
  questionCount: number
  baseEntity?: BaseEntityResponse
}

export interface UpdatePracticeQuizQuestionsRequest {
  questionIds: number[]
}

export interface UpdateFinalQuizQuestionsRequest {
  questionIds: number[]
}

export type CourseNodeStatus = "LOCKED" | "CURRENT" | "COMPLETED"

export interface CourseBlockMapResponse {
  id: number
  title: string
  position: number
  status: CourseNodeStatus
  baseEntity?: BaseEntityResponse
}

export interface CourseLessonMapResponse {
  id: number
  title: string
  position: number
  status: CourseNodeStatus
  blocks: CourseBlockMapResponse[]
  baseEntity?: BaseEntityResponse
}

export interface CourseChapterMapResponse {
  id: number
  title: string
  position: number
  status: CourseNodeStatus
  lessons: CourseLessonMapResponse[]
  baseEntity?: BaseEntityResponse
}

export interface CourseProgressResponse {
  currentChapterId?: number
  currentLessonId?: number
  currentBlockId?: number
  progressPercentage?: number
  completed?: boolean
  completedAt?: string
}

export interface RoadmapResponse {
  id: number
  organization: OrganizationResponse
  items: RoadmapItemResponse[]
  baseEntity?: BaseEntityResponse
}

export interface RoadmapItemResponse {
  id: number
  position: number
  course: CourseResponse
  baseEntity?: BaseEntityResponse
}

export interface UpsertRoadmapRequest {
  courseIds: number[]
}

export interface PracticeExamResponse {
  id: number
  title: string
  description?: string
  courseId: number
  difficulty: QuestionDifficulty
  questions: QuestionResponse[]
  baseEntity?: BaseEntityResponse
}

export interface CreatePracticeExamRequest {
  title: string
  description?: string
  questionIds: number[]
}

export interface UpdatePracticeExamQuestionsRequest {
  questionIds: number[]
}
