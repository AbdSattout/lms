"use no memo"
"use client"

import { useCallback, useEffect, useState } from "react"
import type { Editor } from "@tiptap/react"
import { useTiptapEditor } from "@/hooks/use-tiptap-editor"
import { isExtensionAvailable } from "@/lib/tiptap-utils"

export function canInsertMedia(editor: Editor | null): boolean {
  if (!editor || !editor.isEditable) return false
  if (!isExtensionAvailable(editor, "media")) return false
  return editor.can().insertContent({ type: "media" })
}

export function insertMedia(
  editor: Editor | null,
  mediaId: number,
  attrs?: { orgSlug?: string | null; courseSlug?: string | null }
): boolean {
  if (!editor || !editor.isEditable) return false
  if (!canInsertMedia(editor)) return false

  try {
    return editor
      .chain()
      .focus()
      .insertContent({
        type: "media",
        attrs: { ...attrs, mediaId },
      })
      .run()
  } catch {
    return false
  }
}

export function useMedia(config?: {
  editor?: Editor | null
  hideWhenUnavailable?: boolean
  onInserted?: () => void
  orgSlug?: string | null
  courseSlug?: string | null
}) {
  const {
    editor: providedEditor,
    hideWhenUnavailable = false,
    onInserted,
    orgSlug,
    courseSlug,
  } = config || {}

  const { editor } = useTiptapEditor(providedEditor)
  const [isVisible, setIsVisible] = useState(true)
  const canInsert = canInsertMedia(editor)

  useEffect(() => {
    if (!editor) return

    const handleSelectionUpdate = () => {
      if (!editor || !editor.isEditable) {
        setIsVisible(false)
        return
      }

      if (!hideWhenUnavailable) {
        setIsVisible(true)
        return
      }

      if (!isExtensionAvailable(editor, "media")) {
        setIsVisible(false)
        return
      }

      setIsVisible(canInsertMedia(editor))
    }

    handleSelectionUpdate()
    editor.on("selectionUpdate", handleSelectionUpdate)
    return () => {
      editor.off("selectionUpdate", handleSelectionUpdate)
    }
  }, [editor, hideWhenUnavailable])

  const handleMediaInsert = useCallback(
    (mediaId: number) => {
      if (!editor) return false
      const success = insertMedia(editor, mediaId, { orgSlug, courseSlug })
      if (success) onInserted?.()
      return success
    },
    [editor, onInserted, orgSlug, courseSlug],
  )

  return {
    isVisible,
    canInsert,
    handleMediaInsert,
    label: "Add media",
  }
}
