import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { RoadmapResponse } from "@/lib/api/types"
import { BookOpen, Edit2, MapPin, Trash2 } from "lucide-react"

interface RoadmapCardProps {
  roadmap: RoadmapResponse
  onClick: () => void
  onDelete: () => void
}

export function RoadmapCard({ roadmap, onClick, onDelete }: RoadmapCardProps) {
  return (
    <Card
      onClick={onClick}
      className="group relative cursor-pointer overflow-hidden transition-all duration-200 hover:border-primary/50 hover:shadow-md"
    >
      <div className="absolute top-4 left-4 z-10 flex translate-y-2 gap-2 opacity-0 transition-all group-hover:translate-y-0 group-hover:opacity-100">
        <button
          onClick={(e) => {
            e.stopPropagation()
            onDelete()
          }}
          className="rounded-full bg-destructive/10 p-2 text-destructive transition-colors hover:bg-destructive/20"
        >
          <Trash2 className="h-4 w-4" />
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation()
            onClick()
          }}
          className="rounded-full bg-primary/10 p-2 text-primary transition-colors hover:bg-primary/20"
        >
          <Edit2 className="h-4 w-4" />
        </button>
      </div>

      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-lg">
          <MapPin className="h-5 w-5 text-primary transition-transform group-hover:scale-110" />
          <span>{roadmap.name || "مسار بدون عنوان"}</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center gap-2 text-sm text-muted-foreground transition-colors group-hover:text-foreground">
          <BookOpen className="h-4 w-4 shrink-0" />
          <span className="line-clamp-2">
            {roadmap.description || "لا يوجد وصف لهذا المسار."}
          </span>
        </div>
      </CardContent>
    </Card>
  )
}
