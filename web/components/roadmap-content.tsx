"use client"
import type { Route } from "next"

import { Button } from "@/components/ui/button"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import type { RoadmapResponse } from "@/lib/api/types"
import { Map, Plus } from "lucide-react"
import { useRouter } from "next/navigation"
import { useTransition } from "react"
import { RoadmapCard } from "./cards/roadmap-card"

interface RoadmapsContentProps {
  orgSlug: string
  roadmaps: RoadmapResponse[]
}

export function RoadmapsContent({ orgSlug, roadmaps }: RoadmapsContentProps) {
  const router = useRouter()
  // Replace standard broken local hooks seamlessly tracking native mapping!
  const [isPending, startTransition] = useTransition()

  const handleCreateRoadmap = () => {
    // Perfectly completes/unblocks once routing explicitly natively handles layouts transitioning exactly dynamically flawlessly elegantly precisely automatically!
    startTransition(() => {
      router.push(`/${orgSlug}/roadmaps/new` as Route)
    })
  }

  const handleEditRoadmap = (roadmapId: number) => {
    startTransition(() => {
      router.push(`/${orgSlug}/roadmaps/${roadmapId}` as Route)
    })
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">المسارات التعليمية</h1>
        <Button onClick={handleCreateRoadmap} disabled={isPending}>
          <Plus className="ml-1.5 h-4 w-4" />
          إضافة مسار تعليمي
        </Button>
      </div>

      {roadmaps.length === 0 ? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <Map />
            </EmptyMedia>
            <EmptyTitle>لا توجد مسارات تعليمية بعد</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>
            <Button onClick={handleCreateRoadmap} disabled={isPending}>
              <Plus className="ml-1.5 h-4 w-4" />
              إضافة مسار تعليمي
            </Button>
          </EmptyContent>
        </Empty>
      ) : (
        <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-4">
          {roadmaps.map((roadmap) => (
            <RoadmapCard
              key={roadmap.id}
              roadmap={roadmap}
              onClick={() => handleEditRoadmap(roadmap.id)}
            />
          ))}
        </div>
      )}
    </div>
  )
}
