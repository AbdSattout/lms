import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { RoadmapResponse } from "@/lib/api/types"
import { BookOpen, Edit2, MapPin } from "lucide-react"

interface RoadmapCardProps {
  roadmap: RoadmapResponse
  onClick: () => void
}
export function RoadmapCard({ roadmap, onClick }: RoadmapCardProps) {
  const courseCount = roadmap.items?.length ?? 0

  return (
    <Card
      onClick={onClick}
      className="group relative cursor-pointer overflow-hidden transition-all duration-200 hover:border-primary/50 hover:shadow-md"
    >
      <div className="absolute top-4 left-4 z-10 translate-y-2 rounded-full bg-primary/10 p-2 text-primary opacity-0 transition-all group-hover:translate-y-0 group-hover:opacity-100">
        <Edit2 className="h-4 w-4" />
      </div>

      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-lg">
          <MapPin className="h-5 w-5 text-primary transition-transform group-hover:scale-110" />
          <span>{roadmap.title}</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center gap-2 text-sm text-muted-foreground transition-colors group-hover:text-foreground">
          <BookOpen className="h-4 w-4" />
          <span>
            {courseCount} {courseCount === 1 ? "دورة" : "دورات"}
          </span>
        </div>
      </CardContent>
    </Card>
  )
}
