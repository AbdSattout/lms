"use no memo"
"use client"

import { useCallback, useEffect, useState } from "react"
import type { Editor } from "@tiptap/react"

import { useTiptapEditor } from "@/hooks/use-tiptap-editor"

import { SigmaIcon } from "@/components/tiptap-icons/sigma-icon"

export interface UseMathPopoverConfig {
  editor?: Editor | null
  hideWhenUnavailable?: boolean
  onSetMath?: () => void
}

export function canSetMath(editor: Editor | null): boolean {
  if (!editor || !editor.isEditable) return false
  try {
    return !!editor.extensionManager.extensions.find(
      (ext) => ext.name === "inlineMath" || ext.name === "blockMath"
    )
  } catch {
    return false
  }
}

export function isMathActive(editor: Editor | null): boolean {
  if (!editor || !editor.isEditable) return false
  return editor.isActive("inlineMath") || editor.isActive("blockMath")
}

export function getSelectedMathLatex(editor: Editor | null): string {
  if (!editor) return ""
  const inlineAttrs = editor.getAttributes("inlineMath")
  if (inlineAttrs?.latex) return inlineAttrs.latex
  const blockAttrs = editor.getAttributes("blockMath")
  if (blockAttrs?.latex) return blockAttrs.latex
  return ""
}

export function shouldShowMathButton(props: {
  editor: Editor | null
  hideWhenUnavailable: boolean
}): boolean {
  const { editor, hideWhenUnavailable } = props
  if (!editor || !editor.isEditable) return false
  if (!hideWhenUnavailable) return true
  return canSetMath(editor)
}

export function useMathHandler(props: {
  editor: import("@tiptap/react").Editor | null
  onSetMath?: () => void
}) {
  const { editor, onSetMath } = props
  const [latex, setLatex] = useState<string | null>(null)

  // Sync latex from editor during render when it becomes available
  if (editor && latex === null) {
    const selected = getSelectedMathLatex(editor)
    if (selected) {
      setLatex(selected)
    }
  }

  useEffect(() => {
    if (!editor) return
    const updateMathState = () => {
      const selected = getSelectedMathLatex(editor)
      setLatex(selected)
    }
    editor.on("selectionUpdate", updateMathState)
    return () => {
      editor.off("selectionUpdate", updateMathState)
    }
  }, [editor])

  const insertMath = useCallback(() => {
    if (!latex || !editor) return

    if (editor.isActive("inlineMath")) {
      editor.chain().focus().updateInlineMath({ latex }).run()
    } else if (editor.isActive("blockMath")) {
      editor.chain().focus().updateBlockMath({ latex }).run()
    } else {
      const { selection } = editor.state
      const $from = selection.$from
      const isAtStartOfBlock = $from.parentOffset === 0 && $from.parent.content.size === 0

      if (isAtStartOfBlock) {
        editor.chain().focus().insertBlockMath({ latex }).run()
      } else {
        editor.chain().focus().insertInlineMath({ latex }).run()
      }
    }

    setLatex(null)
    onSetMath?.()
  }, [editor, latex, onSetMath])

  const removeMath = useCallback(() => {
    if (!editor) return
    if (editor.isActive("inlineMath")) {
      editor.chain().focus().deleteInlineMath().run()
    } else if (editor.isActive("blockMath")) {
      editor.chain().focus().deleteBlockMath().run()
    }
    setLatex(null)
  }, [editor])

  return {
    latex: latex || "",
    setLatex,
    insertMath,
    removeMath,
  }
}

export function useMathPopover(config?: UseMathPopoverConfig) {
  const {
    editor: providedEditor,
    hideWhenUnavailable = false,
    onSetMath,
  } = config || {}

  const { editor } = useTiptapEditor(providedEditor)

  const canSet = canSetMath(editor)
  const isActive = isMathActive(editor)

  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    if (!editor) return
    const handleSelectionUpdate = () => {
      setIsVisible(shouldShowMathButton({ editor, hideWhenUnavailable }))
    }
    handleSelectionUpdate()
    editor.on("selectionUpdate", handleSelectionUpdate)
    return () => {
      editor.off("selectionUpdate", handleSelectionUpdate)
    }
  }, [editor, hideWhenUnavailable])

  const mathHandler = useMathHandler({ editor, onSetMath: onSetMath })

  return {
    isVisible,
    canSet,
    isActive,
    label: "رياضيات",
    Icon: SigmaIcon,
    ...mathHandler,
  }
}
