"use no memo"
"use client"

import type { Editor } from "@tiptap/react"
import { useCurrentEditor } from "@tiptap/react"
import { useEffect, useState } from "react"

export function useTiptapEditor(providedEditor?: Editor | null): {
  editor: Editor | null
  editorState?: Editor["state"]
  canCommand?: Editor["can"]
} {
  const { editor: coreEditor } = useCurrentEditor()
  const mainEditor = providedEditor ?? coreEditor

  const [, forceUpdate] = useState(0)

  useEffect(() => {
    if (!mainEditor) return
    const onTransaction = () => forceUpdate((n) => n + 1)
    mainEditor.on("transaction", onTransaction)
    return () => {
      mainEditor.off("transaction", onTransaction)
    }
  }, [mainEditor])

  return {
    editor: mainEditor,
    editorState: mainEditor?.state,
    canCommand: mainEditor?.can,
  }
}
