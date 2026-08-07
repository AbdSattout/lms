"use client"

import { useEffect, useState } from "react"
import Link from "next/link"
import { Crown } from "lucide-react"
import type { User } from "@/lib/api/types"
import { getUserSubscriptionStatus } from "@/lib/actions/billing"

export function SubscriptionButton() {
  const [user, setUser] = useState<User | null>(null)
  const [isPremium, setIsPremium] = useState(false)

  useEffect(() => {
    const fetchUser = async () => {
      const { user } = await getUserSubscriptionStatus()
      console.log("Fetched user:", user)
      setUser(user)
      setIsPremium(user?.plan?.premium ?? false)
    }
    fetchUser()
  }, [])

  return (
    <Link
      href="/payment"
      className="relative inline-flex items-center gap-2 rounded-lg bg-gradient-to-r from-amber-500 to-yellow-500 px-4 py-2 text-sm font-semibold text-white shadow-lg transition-all hover:from-amber-600 hover:to-yellow-600 hover:shadow-xl"
    >
      <Crown className="h-4 w-4" />
      {isPremium ? "Premium" : "ترقية"}
    </Link>
  )
}
