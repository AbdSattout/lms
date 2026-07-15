"use client"

import type { QuestionResponse } from "@/lib/api/types"

export { QuestionsGrid as QuestionBank } from "@/components/questions-grid"
export type QuestionBankProps = {
  questions: QuestionResponse[]
  onClick?: (question: QuestionResponse) => void
  renderActions?: (question: QuestionResponse) => React.ReactNode
}
