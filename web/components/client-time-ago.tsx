"use client"

import { useEffect, useState } from "react"
import { formatDistanceToNow } from "date-fns"
import { ar } from "date-fns/locale"

interface ClientTimeAgoProps {
  date: string
}

export function ClientTimeAgo({ date }: ClientTimeAgoProps) {
  const [timeAgo, setTimeAgo] = useState("")

  useEffect(() => {
    const updateTime = () => {
      const parsedDate = new Date(date)

      if (Number.isNaN(parsedDate.getTime())) {
        setTimeAgo("")
        return
      }

      setTimeAgo(
        formatDistanceToNow(parsedDate, {
          addSuffix: true,
          locale: ar,
        })
      )
    }

    updateTime()

    const interval = window.setInterval(updateTime, 60_000)

    return () => window.clearInterval(interval)
  }, [date])

  return <span>{timeAgo}</span>
}
