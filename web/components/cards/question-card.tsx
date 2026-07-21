"use client"

import { TiptapRenderer } from "@/components/editor/renderer"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { QuestionResponse } from "@/lib/api/types"
import { cn } from "@/lib/utils"
import { EllipsisVertical } from "lucide-react"

const difficultyMap: Record<string, string> = {
  EASY: "سهل",
  MEDIUM: "متوسط",
  HARD: "صعب",
}

interface QuestionCardProps {
  question: QuestionResponse
  onClick?: (question: QuestionResponse) => void
  renderActions?: (question: QuestionResponse) => React.ReactNode
}

export function QuestionCard({
  question,
  onClick,
  renderActions,
}: QuestionCardProps) {
  const handleClick = () => {
    onClick?.(question)
  }

  const hasClickHandler = !!onClick
  const hasActions = !!renderActions

  return (
    <div className="group relative overflow-hidden rounded-4xl border border-border bg-card p-4 transition-colors hover:bg-accent/50">
      <div
        role={hasClickHandler ? "button" : undefined}
        tabIndex={hasClickHandler ? 0 : undefined}
        className={cn(hasClickHandler && "cursor-pointer")}
        onClick={handleClick}
        onKeyDown={(e) => {
          if (e.key === "Enter" && hasClickHandler) handleClick()
        }}
      >
        <div className="question-card-markdown line-clamp-8 text-sm leading-relaxed">
          <TiptapRenderer content={question.content} />
        </div>
      </div>

      <div className="mt-2 text-xs text-muted-foreground">
        {question.options.length} خيارات · {difficultyMap[question.difficulty]}
      </div>

      {hasActions && (
        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            render={
              <Button
                variant="ghost"
                size="icon-sm"
                className="absolute inset-e-2 top-2 opacity-0 transition-opacity group-hover:opacity-100"
              />
            }
          >
            <EllipsisVertical className="size-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent>{renderActions(question)}</DropdownMenuContent>
        </DropdownMenu>
      )}
    </div>
  )
}
