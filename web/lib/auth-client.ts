import { genericOAuthClient } from "better-auth/client/plugins"
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  fetchOptions: {
    credentials: "include",
  },
  plugins: [genericOAuthClient()],
})
