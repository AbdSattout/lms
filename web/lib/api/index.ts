import "server-only"

import { me } from "@/lib/api/users"

export const api = {
  users: {
    me,
  },
}
