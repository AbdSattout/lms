"use client"

import { useRouter } from "next/navigation"
import { useState } from "react"

import { Button } from "@/components/ui/button"

export function LogoutButton() {
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
    <Button variant="outline" onClick={handleLogout} disabled={isSubmitting}>
      {isSubmitting ? "جاري تسجيل الخروج..." : "تسجيل الخروج"}
    </Button>
  )
}
