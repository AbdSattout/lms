import { Geist_Mono, IBM_Plex_Sans_Arabic, Lalezar } from "next/font/google"

import { Toaster } from "@/components/ui/sonner"
import { cn } from "@/lib/utils"
import { ThemeProvider } from "@wrksz/themes/next"
import "./globals.css"

const lalezarHeading = Lalezar({
  weight: "400",
  subsets: ["latin"],
  variable: "--font-heading",
})

const ibmPlexSansArabic = IBM_Plex_Sans_Arabic({
  weight: ["400", "500", "600"],
  subsets: ["latin"],
  variable: "--font-sans",
})

const fontMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
})

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang="ar"
      dir="rtl"
      suppressHydrationWarning
      className={cn(
        "antialiased",
        fontMono.variable,
        "font-sans",
        ibmPlexSansArabic.variable,
        lalezarHeading.variable
      )}
    >
      <body>
        <ThemeProvider>
          <Toaster position="bottom-left" />
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
