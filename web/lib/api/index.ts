import "server-only"

import { login } from "@/lib/api/auth"
import { me } from "@/lib/api/users"
import type { ApiTree } from "@/lib/api/route"

export const api = {
  auth: {
    login,
  },
  users: {
    me,
  },
} satisfies ApiTree
