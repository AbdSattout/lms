"use client"

import { QuestionCard } from "@/components/cards/question-card"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import type { QuestionResponse } from "@/lib/api/types"
import { FileQuestion } from "lucide-react"

interface QuestionBankProps {
  questions: QuestionResponse[]
  mode?: "edit" | "select"
  onEdit?: (question: QuestionResponse) => void
  onDelete?: (question: QuestionResponse) => void
  onSelect?: (question: QuestionResponse) => void
}

export function QuestionBank({
  questions,
  mode = "edit",
  onEdit,
  onDelete,
  onSelect,
}: QuestionBankProps) {
  if (questions.length === 0) {
    return (
      <Empty>
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <FileQuestion />
          </EmptyMedia>
          <EmptyTitle>لا توجد أسئلة</EmptyTitle>
        </EmptyHeader>
        <EmptyContent>
          لم يتم إضافة أسئلة لهذه الدورة بعد. أضف سؤالاً جديداً للبدء.
        </EmptyContent>
      </Empty>
    )
  }

  return (
    <div className="columns-1 gap-4 md:columns-2 xl:columns-3">
      {questions.map((question) => (
        <div key={question.id} className="mb-4 break-inside-avoid">
          <QuestionCard
            mode={mode}
            question={question}
            onEdit={mode === "edit" ? () => onEdit?.(question) : undefined}
            onDelete={mode === "edit" ? () => onDelete?.(question) : undefined}
            onSelect={
              mode === "select" ? () => onSelect?.(question) : undefined
            }
          />
        </div>
      ))}
    </div>
  )
}
