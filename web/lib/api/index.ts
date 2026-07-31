import "server-only"

import { generateQuestionFromBlock, transformText } from "@/lib/api/ai"
import {
  loginWithEmailOtp,
  loginWithGoogle,
  loginWithTelegram,
  requestEmailOtp,
} from "@/lib/api/auth"
import { checkout, portal, revoke } from "@/lib/api/billing"
import {
  byId as blocksById,
  byLesson as blocksByLesson,
  create as createBlock,
  getPublic as getPublicBlock,
  reorder as reorderBlocks,
} from "@/lib/api/blocks"
import {
  getLessons as chapterLessons,
  byId as chaptersById,
} from "@/lib/api/chapters"
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
  list as orgMediaList,
  summary as orgMediaSummary,
} from "@/lib/api/organization-media"
import {
  bySlug,
  checkCourseSlugAvailability,
  checkSlugAvailability,
  courses,
  create as createOrg,
  getCourseBySlug,
  invites,
  joinRequests,
  list,
  members,
} from "@/lib/api/organizations"
import { courseOverview, orgOverview, userOverview } from "@/lib/api/overview"
import {
  byId as postMediaById,
  byOrg as postMediaByOrg,
} from "@/lib/api/post-media"
import {
  comments,
  deleteComment,
  likes,
  byCourse as postsByCourse,
  byId as postsById,
  byOrg as postsByOrg,
} from "@/lib/api/posts"
import {
  create as createPracticeExam,
  deleteExam as deletePracticeExam,
  list as listPracticeExams,
  byId as practiceExamById,
  updateQuestions as updatePracticeExamQuestions,
} from "@/lib/api/practice-exams"
import {
  create as createPracticeQuiz,
  deleteQuiz as deletePracticeQuiz,
  list as listPracticeQuizzes,
  byId as practiceQuizById,
  updateQuestions as updatePracticeQuizQuestions,
} from "@/lib/api/practice-quizzes"
import { create, me as profileMe } from "@/lib/api/profile"
import {
  create as createQuestion,
  byId as questionById,
  byCourse as questionsByCourse,
} from "@/lib/api/questions"
import { getFinalQuiz, updateFinalQuizQuestions } from "@/lib/api/quizzes"
import {
  create as createRoadmap,
  list as listRoadmaps,
  byId as roadmapById,
} from "@/lib/api/roadmap"
import type { ApiTree } from "@/lib/api/route"
import { me, picture, search as userSearch } from "@/lib/api/users"

export const api = {
  auth: {
    loginWithTelegram,
    loginWithGoogle,
    requestEmailOtp,
    loginWithEmailOtp,
  },
  organizations: {
    list,
    joinRequests: {
      create: joinRequests.create,
      cancel: joinRequests.cancel,
    },
  },
  users: {
    me,
    picture,
    search: userSearch,
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
  dashboard: {
    organizations: {
      create: createOrg,
      bySlug,
      courses,
      checkSlugAvailability,
      getCourseBySlug,
      checkCourseSlugAvailability,
      invites,
      members,
      joinRequests: joinRequests.dashboard,
    },
    courses: {
      byId: coursesById,
      publish,
      chapters,
    },
    chapters: {
      byId: chaptersById,
      getLessons: chapterLessons,
    },
    lessons: {
      create: createLesson,
      byId: lessonsById,
      reorder: reorderLessons,
    },
    blocks: {
      create: createBlock,
      byId: blocksById,
      byLesson: blocksByLesson,
      reorder: reorderBlocks,
    },
    media: {
      byCourse,
      byId: mediaById,
    },
    questions: {
      create: createQuestion,
      byCourse: questionsByCourse,
      byId: questionById,
    },
    quizzes: {
      getFinalQuiz,
      updateFinalQuizQuestions,
    },
    practiceQuizzes: {
      create: createPracticeQuiz,
      byId: practiceQuizById,
      list: listPracticeQuizzes,
      updateQuestions: updatePracticeQuizQuestions,
      delete: deletePracticeQuiz,
    },
    practiceExams: {
      create: createPracticeExam,
      byId: practiceExamById,
      list: listPracticeExams,
      updateQuestions: updatePracticeExamQuestions,
      delete: deletePracticeExam,
    },
    roadmap: {
      create: createRoadmap,
      byId: roadmapById,
      list: listRoadmaps,
    },
    posts: {
      byCourse: postsByCourse,
      byId: postsById,
      byOrg: postsByOrg,
      likes,
      comments,
      deleteComment,
    },
    postMedia: {
      byOrg: postMediaByOrg,
      byId: postMediaById,
    },
    organizationMedia: {
      list: orgMediaList,
      summary: orgMediaSummary,
    },
    ai: {
      generateQuestionFromBlock,
      transformText,
    },
    overview: {
      user: userOverview,
      org: orgOverview,
      course: courseOverview,
    },
  },
  billing: {
    checkout,
    portal,
    revoke,
  },
} satisfies ApiTree
