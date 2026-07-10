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
  chapters,
  byId as coursesById,
  enroll,
  publish,
} from "@/lib/api/courses"
import {
  create as createLesson,
  byId as lessonsById,
  reorder as reorderLessons,
} from "@/lib/api/lessons"
import { byCourse, byId as mediaById } from "@/lib/api/media"
import {
  bySlug,
  checkCourseSlugAvailability,
  checkSlugAvailability,
  courses,
  create as createOrg,
  getCourseBySlug,
  list,
} from "@/lib/api/organizations"
import {
  comments,
  deleteComment,
  likes,
  byCourse as postsByCourse,
  byId as postsById,
  byOrg as postsByOrg,
} from "@/lib/api/posts"
import { create, me as profileMe } from "@/lib/api/profile"
import { submitAnswer } from "@/lib/api/progress"
import {
  addQuestion,
  byId as quizById,
  deleteQuestion,
} from "@/lib/api/quizzes"
import { update as updateQuestion } from "@/lib/api/questions"
import type { ApiTree } from "@/lib/api/route"
import { me, picture } from "@/lib/api/users"

export const api = {
  auth: {
    login,
  },
  organizations: {
    list,
  },
  users: {
    me,
    picture,
  },
  profile: {
    create,
    me: profileMe,
  },
  courses: {
    enroll,
  },
  blocks: {
    getPublic: getPublicBlock,
  },
  progress: {
    submitAnswer,
  },

  dashboard: {
    organizations: {
      create: createOrg,
      bySlug,
      courses,
      checkSlugAvailability,
      getCourseBySlug,
      checkCourseSlugAvailability,
    },
    courses: {
      byId: coursesById,
      publish,
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
    },
    media: {
      byCourse,
      byId: mediaById,
    },
    questions: {
      update: updateQuestion,
    },
    quizzes: {
      byId: quizById,
      addQuestion,
      deleteQuestion,
    },
    posts: {
      byCourse: postsByCourse,
      byId: postsById,
      byOrg: postsByOrg,
      likes,
      comments,
      deleteComment,
    },
  },
} satisfies ApiTree
