import { betterAuth } from "better-auth"
import { genericOAuth } from "better-auth/plugins/generic-oauth"
import { decodeJwt } from "jose"

export const auth = betterAuth({
  plugins: [
    genericOAuth({
      config: [
        {
          providerId: "telegram",
          clientId: process.env.AUTH_CLIENT_ID!,
          clientSecret: process.env.AUTH_CLIENT_SECRET!,
          discoveryUrl:
            "https://oauth.telegram.org/.well-known/openid-configuration",
          scopes: ["openid", "profile"],
          getUserInfo: async (tokens) => {
            if (!tokens.idToken) {
              return null
            }

            const claims = decodeJwt(tokens.idToken)

            return {
              id: claims.id as string,
              name: claims.name as string,
              email: `telegram-${claims.id}@users.local`,
              image: claims.picture as string | undefined,
              emailVerified: true,
            }
          },
        },
      ],
    }),
  ],
})
