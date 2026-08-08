import { NextConfig } from "next"

const imageKitUrl =
  process.env.IMAGEKIT_URL ?? "https://ik.imagekit.io/lmsgoesboom"

const nextConfig: NextConfig = {
  reactCompiler: true,
  typedRoutes: true,
  cacheComponents: true,
  partialPrefetching: true,
  images: {
    remotePatterns: [
      new URL("https://t.me/i/userpic/**"),
      new URL(`${imageKitUrl}/**`),
    ],
  },
  experimental: {
    turbopackRustReactCompiler: true,
    instantInsights: {
      validationLevel: "manual-warning",
    },
  },
}

export default nextConfig
