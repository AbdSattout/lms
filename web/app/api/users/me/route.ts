/**
 * this route is *just* an example of bff proxy implementaion,
 * hence it is not necessary nor used anywhere.
 */

import { api } from "@/lib/api"

export async function GET() {
  const me = await api.users.me({ onUnauthorized: "throw" })

  return Response.json(me)
}
