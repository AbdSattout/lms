export interface BaseEntityResponse {
  createdAt: string
  updatedAt: string
}

export interface Plan {
  planId: number
  code: string
  name: string
  premium: boolean
  dailyAiToolLimit: number
  weeklyAiQuizLimit: number
  weeklyCourseEnrollmentLimit: number
  activeRoadmapFollowLimit: number
  randomQuizPerCourseLimit: number
  organizationLimit: number
  organizationCourseLimit: number
  organizationStorageLimitBytes: number
  xpMultiplier: number
  startedAt: string
  expiresAt: string | null
}

export interface User {
  id: number
  name?: string
  username?: string
  picture?: string
  email?: string | null
  plan?: Plan | null
  subscription?: unknown | null
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
  verified?: boolean
  ownerName: string
  membersCount: number
  coursesCount: number
  viewer?: OrganizationViewerResponse
  baseEntity?: BaseEntityResponse
}

export interface OrganizationViewerResponse {
  joined: boolean
  role?: Role
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

export interface OrganizationSummaryResponse {
  id: number
  name: string
  slug: string
  description?: string
  image?: string
  visibility: OrganizationVisibility
  verified?: boolean
}

export interface CourseResponse {
  id: number
  title: string
  slug: string
  description?: string
  coverUrl?: string
  status: CourseStatus
  organization: OrganizationSummaryResponse
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

export type PostReactionType =
  "LIKE" | "LOVE" | "SUPPORT" | "CELEBRATE" | "INSIGHTFUL"

export interface PostResponse {
  id: number
  title: string
  content?: string
  author: AuthorResponse
  organizationId: number
  courseId?: number | null
  likeCount: number
  commentCount: number
  reactionCounts: Record<PostReactionType, number>
  viewerReaction?: PostReactionType
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
  likeCount: number
  reactionCounts: Record<PostReactionType, number>
  viewerReaction?: PostReactionType
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
  "PROFESSIONAL" | "FRIENDLY" | "SIMPLE" | "ACADEMIC" | "MOTIVATIONAL"

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
  ownerPlan: Plan
  membersCount: number
  adminsCount: number
  studentsCount: number
  bannedUsersCount: number
  coursesCount: number
  publishedCoursesCount: number
  draftCoursesCount: number
  postsCount: number
  roadmapsCount: number
  storage: StorageResponse
}
export type OrganizationVerificationStatus = "PENDING" | "APPROVED" | "REJECTED"

export interface OrganizationVerificationResponse {
  id: number
  organization: OrganizationResponse
  requestedBy: UserResponse
  note?: string | null
  proofUrl: string
  status: OrganizationVerificationStatus
  reviewedBy?: AdminResponse | null
  adminNote?: string | null
  reviewedAt?: string | null
  baseEntity?: BaseEntityResponse
}

export interface ReviewOrganizationVerificationRequest {
  status: OrganizationVerificationStatus
  adminNote?: string | null
}

export type PageOrganizationVerificationResponse =
  Page<OrganizationVerificationResponse>
export type PagePostResponse = Page<PostResponse>
export type PageCourseMediaResponse = Page<CourseMediaResponse>

export type Role = "OWNER" | "ADMIN" | "STUDENT"
export type InviteStatus =
  "PENDING" | "ACCEPTED" | "DECLINED" | "EXPIRED" | "CANCELLED"
export type JoinRequestStatus =
  "PENDING" | "ACCEPTED" | "REJECTED" | "CANCELLED"

export interface OrganizationInviteResponse {
  id: number
  userId: number
  userName: string
  role: Role
  status: InviteStatus
  token?: string
  invitedByName: string
  expiresAt: string
  maxUses: number
  usedCount: number
  organization?: OrganizationInviteOrgResponse
  overview?: OrganizationInviteOverviewResponse
  baseEntity?: BaseEntityResponse
}
export interface OrganizationInviteOrgResponse {
  id: number
  name: string
  slug: string
  description?: string
  imageUrl?: string
  visibility: OrganizationVisibility
  owner?: OrganizationInviteOwnerResponse
}
export interface OrganizationInviteOwnerResponse {
  id: number
  name: string
  username?: string
  picture?: string
}
export interface OrganizationInviteOverviewResponse {
  membersCount: number
  adminsCount: number
  studentsCount: number
  coursesCount: number
  publishedCoursesCount: number
  draftCoursesCount: number
  postsCount: number
  roadmapsCount: number
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
  username?: string
  picture: string
  email?: string | null
  phoneNumber?: string | null
}

export interface JoinRequestResponse {
  id: number
  status: JoinRequestStatus
  createdAt: string
  user: UserResponse
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
export type RoadmapStatus = "DRAFT" | "PUBLISHED"
export type RoadmapFollowStatus = "NOT_FOLLOWING" | "ACTIVE" | "COMPLETED"

export interface RoadmapResponse {
  id: number
  name: string
  description?: string
  status: RoadmapStatus
  organization: OrganizationResponse
  items: RoadmapItemResponse[]
  followStatus?: RoadmapFollowStatus
  baseEntity?: BaseEntityResponse
}

export interface RoadmapItemResponse {
  id: number
  position: number
  description?: string
  course: CourseResponse
  baseEntity?: BaseEntityResponse
}

export interface UpsertRoadmapRequest {
  name?: string
  description?: string
  courseIds: number[]
}

export type PracticeExamStatus = "DRAFT" | "PUBLISHED"

export interface PracticeExamResponse {
  id: number
  title: string
  description?: string
  timeLimitMinutes?: number
  status: PracticeExamStatus
  courseId: number
  difficulty: QuestionDifficulty
  questions: QuestionResponse[]
  baseEntity?: BaseEntityResponse
}

export interface CreatePracticeExamRequest {
  title: string
  description?: string
  timeLimitMinutes?: number
  questionIds: number[]
}

export interface UpdatePracticeExamQuestionsRequest {
  questionIds: number[]
}

export interface UserOverviewResponse {
  organizationsCount: number
  enrolledCoursesCount: number
  completedCoursesCount: number
  followingRoadmapsCount: number
  completedRoadmapsCount: number
  certificatesCount: number
  totalXp: number
  currentLevel: number
  currentStreak: number
  longestStreak: number
}

export interface CourseOverviewResponse {
  enrollmentsCount: number
  completedEnrollmentsCount: number
  activeEnrollmentsCount: number
  droppedEnrollmentsCount: number
  chaptersCount: number
  lessonsCount: number
  blocksCount: number
  questionsCount: number
  certificatesCount: number
}

export interface CheckoutSessionResponse {
  checkoutId: string
  checkoutUrl: string
}

export interface CustomerPortalSessionResponse {
  customerPortalUrl: string
}

export type BanDuration = "DAY" | "WEEK" | "MONTH" | "YEAR" | "PERMANENT"

export interface BanRequest {
  reason: string
  duration?: BanDuration
}
export interface OrganizationBanResponse {
  id: number
  user: UserResponse
  bannedByOrgAdmin?: UserResponse | null
  bannedByAppAdmin?: UserResponse | null
  reason?: string | null
  expiresAt?: string | null
  baseEntity?: BaseEntityResponse
}

export type PageOrganizationBanResponse = Page<OrganizationBanResponse>
export interface OrganizationUserSearchResponse {
  name?: string
  email?: string
  phone?: string
  university?: string
  user: UserResponse
  member: boolean
  role?: Role
  invited: boolean
  inviteId?: number
  inviteStatus?: InviteStatus
  inviteRole?: Role
}

export interface GenerateCourseFaqRequest {
  count?: number
  regenerate?: boolean
}

export interface CourseFaqResponse {
  id: number
  question: string
  answer: string
  position?: number
  baseEntity?: BaseEntityResponse
}

export type CertificateGrade = "BASIC" | "GOOD" | "VERY_GOOD" | "EXCELLENT"

export type ConversationType = "DIRECT" | "COURSE"

export interface ConversationResponse {
  id: number
  type: ConversationType
  courseId?: number | null
  directUserOneId?: number | null
  directUserTwoId?: number | null
  lastMessagePreview?: string | null
  lastMessageAt?: string | null
}

export type ChatMessageType = "TEXT"

export interface ChatMessageResponse {
  id: number
  conversationId: number
  senderId: number
  senderName: string
  content?: string | null
  type: ChatMessageType
  createdAt: string
  editedAt?: string | null
  deletedAt?: string | null
}

export interface ChatMuteResponse {
  id: number
  userId: number
  courseId?: number | null
  conversationId?: number | null
  mutedUntil: string
  reason?: string | null
  createdByInstructorId: number
}

export interface ChatMuteUserRequest {
  userId: number
  courseId: number
  conversationId: number
  durationMinutes: number
  reason?: string
}

export type PageChatMessageResponse = Page<ChatMessageResponse>

export interface CertificateResponse {
  certificateCode: string
  studentName: string
  courseName: string
  organizationName: string
  finalQuizScore: number
  finalQuizTotal: number
  finalQuizPercentage: number
  grade: CertificateGrade
  baseEntity?: BaseEntityResponse
}
export type ReportStatus = "PENDING" | "UNDER_REVIEW" | "RESOLVED" | "REJECTED"

export type ReportTargetType =
  "POST" | "COMMENT" | "USER" | "ORGANIZATION" | "COURSE"

export interface ReportReporter {
  id: number
  name: string
  username?: string
  picture?: string | null
}

export interface ReportAdminResponse {
  id: number
  name: string
  email: string
  role: string
  enabled: boolean
}
export interface ReportTargetResponse {
  userId?: number | null
  organizationId?: number | null
  courseId?: number | null
  postId?: number | null
  commentId?: number | null
  exists: boolean
}
export interface ReportResponse {
  id: number
  reporter: ReportReporter
  targetType: ReportTargetType
  target: ReportTargetResponse
  reason: string
  status: ReportStatus
  adminNote?: string | null
  adminResponse?: ReportAdminResponse | null
  baseEntityResponse?: BaseEntityResponse
  reviewedAt?: string | null
}

export interface ReportPageResponse {
  content: ReportResponse[]
  totalElements: number
  totalPages: number
  number?: number
  size?: number
}

export interface ReportReviewRequest {
  status: ReportStatus
  adminNote?: string | null
}
export type AdminRole = "SUPER_ADMIN" | "MODERATOR"
export interface AdminResponse {
  id: number
  name: string
  email: string
  role: AdminRole
  enabled: boolean
}

export interface BannedUserResponse {
  id: number
  user: UserResponse
  bannedBy: AdminResponse
  reason: string
  expiresAt: string | null
  baseEntity?: BaseEntityResponse
}

export interface BannedOrganizationResponse {
  id: number
  organization: OrganizationSummaryResponse
  bannedBy: AdminResponse
  reason: string
  expiresAt: string | null
  baseEntity?: BaseEntityResponse
}
export type PageBannedUserResponse = Page<BannedUserResponse>

export type PageBannedOrganizationResponse = Page<BannedOrganizationResponse>
export interface CreateModeratorRequest {
  name: string
  email: string
  password: string
}

export type PageModeratorResponse = Page<AdminResponse>
