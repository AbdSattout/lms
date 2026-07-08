import { NextConfig } from "next"

const imageKitUrl =
  process.env.IMAGEKIT_URL ?? "https://ik.imagekit.io/lmsgoesboom"

const nextConfig: NextConfig = {
  reactCompiler: true,
  typedRoutes: true,
  allowedDevOrigins: ["127.0.0.1", "localhost:3000"],
  skipProxyUrlNormalize: true,
  images: {
    remotePatterns: [
      new URL("https://t.me/i/userpic/**"),
      new URL(`${imageKitUrl}/**`),
    ],
  },
}

export default nextConfig
