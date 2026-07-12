"use client"

import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { QuestionResponse } from "@/lib/api/types"
import { cn } from "@/lib/utils"
import { EllipsisVertical, Pen, Trash2 } from "lucide-react"
import ReactMarkdown from "react-markdown"
import remarkGfm from "remark-gfm"
import "./question-card.scss"

function buildMarkdown(question: QuestionResponse): string {
  const options = question.options ?? []
  const lines = options.map(
    (opt, i) => `- [${i === question.correctAnswerIndex ? "x" : " "}] ${opt}`
  )
  return [question.content, "", ...lines].join("\n")
}

interface QuestionCardProps {
  question: QuestionResponse
  mode?: "edit" | "select"
  onEdit?: (question: QuestionResponse) => void
  onDelete?: (question: QuestionResponse) => void
  onSelect?: (question: QuestionResponse) => void
}

export function QuestionCard({
  question,
  mode = "edit",
  onEdit,
  onDelete,
  onSelect,
}: QuestionCardProps) {
  const md = buildMarkdown(question)

  const interactive = mode === "edit" ? !!onEdit : !!onSelect
  const handleClick = () => {
    if (mode === "edit") onEdit?.(question)
    else onSelect?.(question)
  }

  return (
    <div className="group relative overflow-hidden rounded-4xl border border-border bg-card p-4 transition-colors hover:bg-accent/50">
      <div
        role={interactive ? "button" : undefined}
        tabIndex={interactive ? 0 : undefined}
        className={cn(interactive && "cursor-pointer")}
        onClick={handleClick}
        onKeyDown={(e) => {
          if (e.key === "Enter" && interactive) handleClick()
        }}
      >
        <div className="question-card-markdown line-clamp-8 text-sm leading-relaxed">
          <ReactMarkdown remarkPlugins={[remarkGfm]}>{md}</ReactMarkdown>
        </div>
      </div>

      {mode === "edit" && (
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
          <DropdownMenuContent>
            <DropdownMenuItem
              onClick={(e) => {
                e.stopPropagation()
                onEdit?.(question)
              }}
            >
              <Pen />
              تعديل
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              variant="destructive"
              onClick={(e) => {
                e.stopPropagation()
                onDelete?.(question)
              }}
            >
              <Trash2 />
              حذف
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </div>
  )
}
