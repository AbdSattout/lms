import { z } from "zod"

export const organizationVisibilitySchema = z.enum(["PUBLIC", "PRIVATE"])
export const fileTypeSchema = z.enum(["IMAGE", "VIDEO", "FILE"])

export const slugSchema = z
  .string()
  .regex(
    /^[a-z0-9-]+$/,
    "الرابط يجب أن يحتوي على أحرف إنجليزية صغيرة وشرطات فقط"
  )

export const createQuestionSchema = z.object({
  content: z.string().min(1, "محتوى السؤال مطلوب"),
  options: z.array(z.string()).min(2, "يجب توفير خيارين على الأقل"),
  correctAnswerIndex: z.number().int().min(0),
})
export type CreateQuestionInput = z.infer<typeof createQuestionSchema>

export const updateUserSchema = z.object({
  name: z.string().min(1, "الاسم مطلوب").optional(),
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
  isPublished: z.boolean().optional(),
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
  question: createQuestionSchema.optional(),
})
export type CreateBlockInput = z.infer<typeof createBlockSchema>

export const updateBlockSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  content: z.string().optional(),
})
export type UpdateBlockInput = z.infer<typeof updateBlockSchema>

export const reorderBlocksSchema = z.object({
  blockIds: z.array(z.number().int()).min(1, "يجب توفير معرف بلوك واحد على الأقل"),
})
export type ReorderBlocksInput = z.infer<typeof reorderBlocksSchema>

export const submitBlockAnswerSchema = z.object({
  answerIndex: z.number().int().min(0),
})
export type SubmitBlockAnswerInput = z.infer<typeof submitBlockAnswerSchema>

export const updateQuestionSchema = z.object({
  content: z.string().optional(),
  options: z.array(z.string()).min(2, "يجب توفير خيارين على الأقل").optional(),
  correctAnswerIndex: z.number().int().min(0).optional(),
})
export type UpdateQuestionInput = z.infer<typeof updateQuestionSchema>

export const createPostSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب"),
  content: z.string().min(1, "المحتوى مطلوب"),
})
export type CreatePostInput = z.infer<typeof createPostSchema>

export const updatePostSchema = z.object({
  title: z.string().min(1, "العنوان مطلوب").optional(),
  content: z.string().min(1, "المحتوى مطلوب").optional(),
})
export type UpdatePostInput = z.infer<typeof updatePostSchema>

export const createCommentSchema = z.object({
  content: z.string().min(1, "محتوى التعليق مطلوب"),
  parentCommentId: z.number().int().optional(),
})
export type CreateCommentInput = z.infer<typeof createCommentSchema>

export const pageableSchema = z.object({
  page: z.number().int().min(0).optional(),
  size: z.number().int().min(1).optional(),
  sort: z.array(z.string()).optional(),
})
export type PageableInput = z.infer<typeof pageableSchema>
