"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import type { RoadmapResponse } from "@/lib/api/types"
import { BookOpen, Edit2, Loader2, MapPin, Trash2 } from "lucide-react"

interface RoadmapCardProps {
  roadmap: RoadmapResponse
  onClick: () => void
  onDelete: () => void
  onStatusToggle: () => void
  isStatusPending: boolean
}

export function RoadmapCard({
  roadmap,
  onClick,
  onDelete,
  onStatusToggle,
  isStatusPending,
}: RoadmapCardProps) {
  const isPublished = roadmap.status === "PUBLISHED"

  return (
    <Card
      dir="rtl"
      onClick={onClick}
      className="group relative cursor-pointer overflow-hidden transition-all duration-200 hover:border-primary/50 hover:shadow-md"
    >
      <div className="absolute top-4 right-4 z-10">
        <span
          className={[
            "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium",
            isPublished
              ? "bg-emerald-500/10 text-emerald-500"
              : "bg-muted text-muted-foreground",
          ].join(" ")}
        >
          {isPublished ? "منشور" : "مسودة"}
        </span>
      </div>

      <div className="absolute top-4 left-4 z-10 flex items-center gap-1.5">
        <Button
          type="button"
          size="sm"
          variant={isPublished ? "outline" : "default"}
          disabled={isStatusPending}
          onClick={(e) => {
            e.stopPropagation()
            onStatusToggle()
          }}
          className="h-8 px-3 text-xs opacity-0 transition-opacity group-hover:opacity-100"
        >
          {isStatusPending && (
            <Loader2 className="ml-1.5 h-3.5 w-3.5 animate-spin" />
          )}

          {isPublished ? "مسودة" : "نشر"}
        </Button>

        <Button
          type="button"
          variant="ghost"
          size="icon"
          onClick={(e) => {
            e.stopPropagation()
            onDelete()
          }}
          className="h-8 w-8 text-destructive opacity-0 transition-opacity group-hover:opacity-100 hover:bg-destructive/10 hover:text-destructive"
        >
          <Trash2 className="h-4 w-4" />
        </Button>

        <Button
          type="button"
          variant="ghost"
          size="icon"
          onClick={(e) => {
            e.stopPropagation()
            onClick()
          }}
          className="h-8 w-8 text-primary opacity-0 transition-opacity group-hover:opacity-100 hover:bg-primary/10 hover:text-primary"
        >
          <Edit2 className="h-4 w-4" />
        </Button>
      </div>

      <CardHeader className="pt-14 pr-4 pb-3 pl-4">
        <CardTitle className="flex items-center gap-2 text-lg">
          <MapPin className="h-5 w-5 shrink-0 text-primary transition-transform group-hover:scale-110" />

          <span className="truncate">{roadmap.name || "مسار بدون عنوان"}</span>
        </CardTitle>
      </CardHeader>

      <CardContent className="pb-5">
        <div className="flex items-start gap-2 text-sm text-muted-foreground transition-colors group-hover:text-foreground">
          <BookOpen className="mt-0.5 h-4 w-4 shrink-0" />

          <span className="line-clamp-2">
            {roadmap.description || "لا يوجد وصف لهذا المسار."}
          </span>
        </div>
      </CardContent>
    </Card>
  )
}
