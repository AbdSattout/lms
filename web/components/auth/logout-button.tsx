"use client"

import { useRouter } from "next/navigation"
import { useState } from "react"
import { Button } from "@/components/ui/button"

interface LogoutButtonProps {
  children?: React.ReactNode
  variant?:
    "default" | "destructive" | "outline" | "secondary" | "ghost" | "link"
  size?: "default" | "sm" | "lg" | "icon"
  className?: string
}

export function LogoutButton({
  children,
  variant = "outline",
  size = "default",
  className,
}: LogoutButtonProps) {
  const router = useRouter()
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleLogout = async () => {
    try {
      setIsSubmitting(true)
      await fetch("/api/auth/logout", {
        method: "POST",
      })
      router.push("/login")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Button
      variant={variant}
      size={size}
      className={className}
      onClick={handleLogout}
      disabled={isSubmitting}
    >
      {children || (isSubmitting ? "جاري تسجيل الخروج..." : "تسجيل الخروج")}
    </Button>
  )
}
