import { Handle, Position, type Node, type NodeProps } from "@xyflow/react"
import { BookOpen, Trash2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import type { CourseResponse } from "@/lib/api/types"
import { cn } from "@/lib/utils"

export type CourseNodeData = {
  course: CourseResponse
  position: number
}

export type CourseNode = Node<CourseNodeData, "courseNode">

export function CourseNode({ data, id }: NodeProps<CourseNode>) {
  const course = data.course as CourseResponse
  const pos = data.position as number

  const statusColor: Record<string, string> = {
    PUBLISHED: "border-emerald-500 bg-emerald-50 dark:bg-emerald-950/20",
    DRAFT: "border-amber-500 bg-amber-50 dark:bg-amber-950/20",
  }

  const colorClass = statusColor[course.status] ?? "border-muted bg-card"
  const label = course.status === "PUBLISHED" ? "منشور" : "مسودة"

  const handleDelete = () => {
    const event = new CustomEvent("remove-node", { detail: { nodeId: id } })
    window.dispatchEvent(event)
  }

  return (
    <div
      dir="rtl"
      className={cn(
        "relative max-w-[280px] min-w-[230px] rounded-lg border-2 p-4 shadow-sm transition-all hover:shadow-lg",
        colorClass
      )}
    >
      <Handle
        type="target"
        position={Position.Top}
        className="!h-4 !w-4 !border-2 !border-background !bg-primary shadow-md"
        style={{ zIndex: 100 }}
        isConnectable={true}
        id="top"
      />

      <div className="pointer-events-auto relative z-10 flex cursor-grab items-start justify-between gap-3">
        <div className="flex-1 space-y-1">
          <div className="flex items-center gap-2">
            <BookOpen className="h-4 w-4 shrink-0 text-primary" />
            <h3 className="text-base font-semibold text-foreground/90">
              {course.title}
            </h3>
          </div>
          {course.description && (
            <p className="line-clamp-2 pt-1 text-xs text-muted-foreground">
              {course.description}
            </p>
          )}
        </div>

        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8 shrink-0 cursor-pointer text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
          onClick={handleDelete}
        >
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>

      <div className="mt-3 flex items-center justify-between border-t border-primary/10 pt-2">
        <span className="text-xs font-medium text-muted-foreground">
          {label}
        </span>
        <span className="rounded-full bg-primary/10 px-2 py-[2px] text-[11px] font-bold text-primary">
          خطوة #{pos + 1}
        </span>
      </div>

      <Handle
        type="source"
        position={Position.Bottom}
        className="!h-4 !w-4 !border-2 !border-background !bg-primary shadow-md"
        style={{ zIndex: 100 }}
        isConnectable={true}
        id="bottom"
      />
    </div>
  )
}
