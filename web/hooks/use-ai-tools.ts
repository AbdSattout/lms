// hooks/use-ai-tools.ts
"use client"

import { useState, useCallback } from "react"
import type { Editor } from "@tiptap/react"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"
import { transformTextAction } from "@/lib/actions/ai-actions"

interface UseAiToolsProps {
  editor: Editor | null
}

export function useAiTools({ editor }: UseAiToolsProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [selectedAction, setSelectedAction] = useState<AiTextAction | null>(
    null
  )
  const [selectedTone, setSelectedTone] = useState<AiTextTone | null>(null)

  const handleAiAction = useCallback(
    async (action: AiTextAction, tone?: AiTextTone) => {
      if (!editor) return

      const { from, to, empty } = editor.state.selection
      const selectedText = empty
        ? editor.state.doc.textContent
        : editor.state.doc.textBetween(from, to)

      if (!selectedText.trim()) {
        setError("No text selected")
        return
      }

      setIsLoading(true)
      setError(null)
      setSelectedAction(action)
      if (tone) setSelectedTone(tone)

      try {
        const response = await transformTextAction(selectedText, action, tone)

        if (response.result) {
          if (empty) {
            // Replace entire content if nothing is selected
            editor.commands.setContent(response.result)
          } else {
            // Replace only the selected text
            editor
              .chain()
              .focus()
              .deleteSelection()
              .insertContent(response.result)
              .run()
          }
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to process text")
        console.error("AI transformation error:", err)
      } finally {
        setIsLoading(false)
        setSelectedAction(null)
        setSelectedTone(null)
      }
    },
    [editor]
  )

  const clearError = useCallback(() => setError(null), [])

  return {
    isLoading,
    error,
    selectedAction,
    selectedTone,
    handleAiAction,
    clearError,
  }
}
