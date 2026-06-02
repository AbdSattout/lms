import "server-only"

import { login } from "@/lib/api/auth"
import { byId as chaptersById } from "@/lib/api/chapters"
import { byId as coursesById, chapters, enroll, publish } from "@/lib/api/courses"
import { bySlug, courses, list } from "@/lib/api/organizations"
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
} satisfies ApiTree
