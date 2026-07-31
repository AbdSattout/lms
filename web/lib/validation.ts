import { z } from "zod"

export const organizationVisibilitySchema = z.enum(["PUBLIC", "PRIVATE"])
export const fileTypeSchema = z.enum(["IMAGE", "VIDEO", "FILE"])

export const slugSchema = z
  .string()
  .regex(
    /^[a-z0-9-]+$/,
    "الرابط يجب أن يحتوي على أحرف إنجليزية صغيرة وشرطات فقط"
  )

export const questionDifficultySchema = z.enum(["EASY", "MEDIUM", "HARD"])

export const createQuestionSchema = z.object({
  content: z.string().min(1, "محتوى السؤال مطلوب"),
  options: z.array(z.string()).min(2, "يجب توفير خيارين على الأقل"),
  correctAnswerIndex: z.number().int().min(0),
  shuffleOptions: z.boolean().optional(),
  difficulty: questionDifficultySchema.optional(),
})
export type CreateQuestionInput = z.infer<typeof createQuestionSchema>

export const usernameSchema = z
  .string()
  .min(3, "اسم المستخدم يجب أن يكون 3 أحرف على الأقل")
  .max(30, "اسم المستخدم طويل جداً")
  .regex(
    /^[a-z0-9_]+$/,
    "اسم المستخدم يجب أن يحتوي على أحرف إنجليزية صغيرة وأرقام وشرطة سفلية فقط"
  )

export const updateUserSchema = z.object({
  name: z.string().min(1, "الاسم مطلوب").optional(),
  username: usernameSchema.optional(),
})
export type UpdateUserInput = z.infer<typeof updateUserSchema>

export const createProfileSchema = z.object({
  email: z.email("البريد الإلكتروني غير صالح").optional(),
  phone: z.string().optional(),
  university: z.string().optional(),
})
export type CreateProfileInput = z.infer<typeof createProfileSchema>

export const updateProfileSchema = z.object({
  email: z.email("البريد الإلكتروني غير صالح").optional(),
  phone: z.string().optional(),
  university: z.string().optional(),
})
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>

export const createOrganizationSchema = z.object({
  name: z.string().min(1, "اسم المنظمة مطلوب"),
  slug: slugSchema.min(1, "الرابط مطلوب"),
  description: z.string().min(1, "الوصف مطلوب"),
  visibility: organizationVisibilitySchema,
})
export type CreateOrganizationInput = z.infer<typeof createOrganizationSchema>

export const updateOrganizationSchema = z.object({
  name: z.string().min(1, "الاسم مطلوب").optional(),
  slug: slugSchema.optional(),
  description: z.string().optional(),
  visibility: organizationVisibilitySchema.optional(),
})
export type UpdateOrganizationInput = z.infer<typeof updateOrganizationSchema>

export const createCourseSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
  slug: slugSchema.min(1, "الرابط مطلوب"),
  description: z.string().optional(),
})
export type CreateCourseInput = z.infer<typeof createCourseSchema>

export const updateCourseSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  slug: slugSchema.min(1, "الرابط مطلوب").optional(),
  description: z.string().optional(),
})
export type UpdateCourseInput = z.infer<typeof updateCourseSchema>

export const createChapterSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
})
export type CreateChapterInput = z.infer<typeof createChapterSchema>

export const updateChapterSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
})
export type UpdateChapterInput = z.infer<typeof updateChapterSchema>

export const reorderChaptersSchema = z.object({
  chapterIds: z
    .array(z.number().int())
    .min(1, "يجب توفير معرف فصل واحد على الأقل"),
})
export type ReorderChaptersInput = z.infer<typeof reorderChaptersSchema>

export const createLessonSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
})
export type CreateLessonInput = z.infer<typeof createLessonSchema>

export const updateLessonSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  chapterId: z.number().int().positive("معرف الفصل غير صالح").optional(),
})
export type UpdateLessonInput = z.infer<typeof updateLessonSchema>

export const reorderLessonsSchema = z.object({
  lessonIds: z
    .array(z.number().int())
    .min(1, "يجب توفير معرف درس واحد على الأقل"),
})
export type ReorderLessonsInput = z.infer<typeof reorderLessonsSchema>

export const createBlockSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
  content: z.string().optional(),
  questionId: z.number().int().positive("معرف السؤال مطلوب"),
})
export type CreateBlockInput = z.infer<typeof createBlockSchema>

export const updateQuestionSchema = z.object({
  content: z.string().optional(),
  options: z.array(z.string()).min(2, "يجب توفير خيارين على الأقل").optional(),
  correctAnswerIndex: z.number().int().min(0).optional(),
  difficulty: questionDifficultySchema.optional(),
})
export type UpdateQuestionInput = z.infer<typeof updateQuestionSchema>

export const updateBlockSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  content: z.string().optional(),
  questionId: z.number().int().positive("معرف السؤال غير صالح").optional(),
})
export type UpdateBlockInput = z.infer<typeof updateBlockSchema>

export const reorderBlocksSchema = z.object({
  blockIds: z
    .array(z.number().int())
    .min(1, "يجب توفير معرف بلوك واحد على الأقل"),
})
export type ReorderBlocksInput = z.infer<typeof reorderBlocksSchema>

export const createPostSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
  content: z.string().min(1, "المحتوى مطلوب"),
  courseId: z.number().int().nullish(),
})
export type CreatePostInput = z.infer<typeof createPostSchema>

export const updatePostSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  content: z.string().min(1, "المحتوى مطلوب").optional(),
  courseId: z.number().optional().nullable(),
})
export type UpdatePostInput = z.infer<typeof updatePostSchema>

export const createCommentSchema = z.object({
  content: z.string().min(1, "محتوى التعليق مطلوب"),
  parentCommentId: z.number().int().optional().nullish(),
})
export type CreateCommentInput = z.infer<typeof createCommentSchema>

export const pageableSchema = z.object({
  page: z.number().int().min(0).optional(),
  size: z.number().int().min(1).optional(),
  sort: z.array(z.string()).optional(),
})
export type PageableInput = z.infer<typeof pageableSchema>

export const generateQuestionFromBlockContentSchema = z.object({
  blockContent: z.string().min(1).max(15000),
})
export type GenerateQuestionFromBlockContentInput = z.infer<
  typeof generateQuestionFromBlockContentSchema
>

export const aiTextActionSchema = z.enum([
  "PROOFREAD",
  "REWRITE",
  "SUMMARIZE",
  "EXPAND",
  "CHANGE_TONE",
  "WRITE",
])

export const aiTextToneSchema = z.enum([
  "PROFESSIONAL",
  "FRIENDLY",
  "SIMPLE",
  "ACADEMIC",
  "MOTIVATIONAL",
])

export const generateAiTextSchema = z.object({
  text: z.string().min(1).max(10000),
  action: aiTextActionSchema,
  tone: aiTextToneSchema.optional(),
})
export type GenerateAiTextInput = z.infer<typeof generateAiTextSchema>

export const createPracticeQuizSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
  description: z.string().optional(),
  questionIds: z.array(z.number().int()),
})
export type CreatePracticeQuizInput = z.infer<typeof createPracticeQuizSchema>

export const updatePracticeQuizQuestionsSchema = z.object({
  questionIds: z
    .array(z.number().int())
    .min(1, "يجب اختيار سؤال واحد على الأقل"),
})
export type UpdatePracticeQuizQuestionsInput = z.infer<
  typeof updatePracticeQuizQuestionsSchema
>

export const upsertRoadmapSchema = z.object({
  courseIds: z.array(z.number().int()).min(1, "يجب اختيار كورس واحد على الأقل"),
})
export type UpsertRoadmapInput = z.infer<typeof upsertRoadmapSchema>
