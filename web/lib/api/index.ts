import "server-only"

import { me } from "@/lib/api/users"
import type { ApiTree } from "@/lib/api/route"

export const api = {
  users: {
    me,
  },
} satisfies ApiTree
