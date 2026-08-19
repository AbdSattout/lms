// hooks/use-ai-tools.ts
"use client"

import { transformTextAction } from "@/lib/actions/ai-actions"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"
import type { Editor } from "@tiptap/react"
import { useCallback, useState } from "react"
import { toast } from "sonner"

interface UseAiToolsProps {
  editor: Editor | null
}

export function useAiTools({ editor }: UseAiToolsProps) {
  const [isLoading, setIsLoading] = useState(false)
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
        toast.error(
          "لم يتم العثور على محتوى. يرجى إدخال نص قبل استخدام أدوات الذكاء الاصطناعي."
        )
        return
      }

      setIsLoading(true)
      setSelectedAction(action)
      if (tone) setSelectedTone(tone)

      try {
        const response = await transformTextAction(selectedText, action, tone)

        if (response.result) {
          if (empty) {
            editor.commands.setContent(response.result, {
              contentType: "markdown",
            })
          } else {
            const parsed = editor.storage.markdown.manager.parse(
              response.result
            )
            const inlineContent = parsed.content?.[0]
            const isSinglePara =
              parsed.content?.length === 1 &&
              inlineContent?.type === "paragraph"

            if (isSinglePara && inlineContent?.content?.length) {
              editor
                .chain()
                .focus()
                .deleteSelection()
                .insertContent(inlineContent.content)
                .run()
            } else {
              editor
                .chain()
                .focus()
                .deleteSelection()
                .insertContent(response.result, {
                  contentType: "markdown",
                })
                .run()
            }
          }
        } else {
          toast.error("حدث خطأ أثناء معالجة النص.")
        }
      } catch (err) {
        if (err instanceof TypeError && err.message.includes("fetch")) {
          toast.error(
            "خطأ في الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت وإعادة المحاولة."
          )
        } else {
          toast.error(
            err instanceof Error ? err.message : "فشل في معالجة النص المحدد."
          )
        }
        console.error("AI transformation error:", err)
      } finally {
        setIsLoading(false)
        setSelectedAction(null)
        setSelectedTone(null)
      }
    },
    [editor]
  )

  return {
    isLoading,
    selectedAction,
    selectedTone,
    handleAiAction,
  }
}
