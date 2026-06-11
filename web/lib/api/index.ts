import "server-only"

import { login } from "@/lib/api/auth"
import {
  byId as blocksById,
  create as createBlock,
  getPublic as getPublicBlock,
  reorder as reorderBlocks,
} from "@/lib/api/blocks"
import { byId as chaptersById } from "@/lib/api/chapters"
import {
  byId as coursesById,
  chapters,
  enroll,
  publish,
} from "@/lib/api/courses"
import { byId as lessonsById, create as createLesson, reorder as reorderLessons } from "@/lib/api/lessons"
import { byCourse, byId as mediaById } from "@/lib/api/media"
import { bySlug, checkSlugAvailability, courses, list } from "@/lib/api/organizations"
import {
  byCourse as postsByCourse,
  byId as postsById,
  comments,
  deleteComment,
  likes,
} from "@/lib/api/posts"
import { create, me as profileMe } from "@/lib/api/profile"
import { me, picture } from "@/lib/api/users"
import type { ApiTree } from "@/lib/api/route"

export const api = {
  auth: {
    login,
  },
  profile: {
    create,
    me: profileMe,
  },
  users: {
    me,
    picture,
  },
  organizations: {
    list,
    bySlug,
    courses,
    checkSlugAvailability,
  },
  courses: {
    byId: coursesById,
    publish,
    enroll,
    chapters,
  },
  chapters: {
    byId: chaptersById,
  },
  lessons: {
    create: createLesson,
    byId: lessonsById,
    reorder: reorderLessons,
  },
  blocks: {
    create: createBlock,
    byId: blocksById,
    reorder: reorderBlocks,
    getPublic: getPublicBlock,
  },
  media: {
    byCourse,
    byId: mediaById,
  },
  posts: {
    byCourse: postsByCourse,
    byId: postsById,
    likes,
    comments,
    deleteComment,
  },
} satisfies ApiTree
