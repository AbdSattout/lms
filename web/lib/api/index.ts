import "server-only"

import { login } from "@/lib/api/auth"
import {
  byId as blocksById,
  byLesson as blocksByLesson,
  create as createBlock,
  getPublic as getPublicBlock,
  reorder as reorderBlocks,
} from "@/lib/api/blocks"
import {
  byId as chaptersById,
  getLessons as chapterLessons,
} from "@/lib/api/chapters"
import {
  checkout,
  portal,
  revoke,
} from "@/lib/api/billing"
import {
  userDashboard,
  organizationDashboard,
} from "@/lib/api/analytics"
import { overview } from "@/lib/api/org-overview"
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
  invites,
  joinRequests,
  list,
  members,
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
import { getFinalQuiz, updateFinalQuizQuestions } from "@/lib/api/quizzes"
import {
  byId as practiceQuizById,
  create as createPracticeQuiz,
  deleteQuiz as deletePracticeQuiz,
  list as listPracticeQuizzes,
  updateQuestions as updatePracticeQuizQuestions,
} from "@/lib/api/practice-quizzes"
import {
  byId as practiceExamById,
  create as createPracticeExam,
  deleteExam as deletePracticeExam,
  list as listPracticeExams,
  updateQuestions as updatePracticeExamQuestions,
} from "@/lib/api/practice-exams"
import {
  byId as roadmapById,
  create as createRoadmap,
  list as listRoadmaps,
} from "@/lib/api/roadmap"
import {
  byCourse as questionsByCourse,
  byId as questionById,
  create as createQuestion,
} from "@/lib/api/questions"
import type { ApiTree } from "@/lib/api/route"
import { me, picture, search as userSearch } from "@/lib/api/users"
import { generateQuestionFromBlock, transformText } from "@/lib/api/ai"
import {
  byOrg as postMediaByOrg,
  byId as postMediaById,
} from "@/lib/api/post-media"
import {
  list as orgMediaList,
  summary as orgMediaSummary,
} from "@/lib/api/organization-media"

export const api = {
  auth: {
    login,
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
      members: {
        list: members.list,
        getOwners: members.getOwners,
        getAdmins: members.getAdmins,
        getStudents: members.getStudents,
      },
      joinRequests: joinRequests.dashboard,
      overview: overview,
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
        analytics: {
      user: userDashboard,
      organization: organizationDashboard,
    },
  },
    billing: {
    checkout,
    portal,
    revoke,
  },
} satisfies ApiTree
