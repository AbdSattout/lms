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

interface QuestionsGridProps {
  questions: QuestionResponse[]
  onClick?: (question: QuestionResponse) => void
  renderActions?: (question: QuestionResponse) => React.ReactNode
  empty?: React.ReactNode
}

export function QuestionsGrid({
  questions,
  onClick,
  renderActions,
  empty,
}: QuestionsGridProps) {
  if (questions.length === 0) {
    return (
      empty ?? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <FileQuestion />
            </EmptyMedia>
            <EmptyTitle>لا توجد أسئلة</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>لم يتم إضافة أسئلة بعد.</EmptyContent>
        </Empty>
      )
    )
  }

  return (
    <div className="@container columns-1 gap-4 @2xl:columns-2 @4xl:columns-3 @6xl:columns-4">
      {questions.map((question) => (
        <div key={question.id} className="mb-4 break-inside-avoid">
          <QuestionCard
            question={question}
            onClick={onClick}
            renderActions={renderActions}
          />
        </div>
      ))}
    </div>
  )
}
