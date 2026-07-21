"use client"

import { EditorContent, useEditor } from "@tiptap/react"
import { useEffect } from "react"
import { rendererExtensions } from "./editor-config"

import "@/components/tiptap-node/blockquote-node/blockquote-node.scss"
import "@/components/tiptap-node/code-block-node/code-block-node.scss"
import "@/components/tiptap-node/heading-node/heading-node.scss"
import "@/components/tiptap-node/horizontal-rule-node/horizontal-rule-node.scss"
import "@/components/tiptap-node/list-node/list-node.scss"
import "@/components/tiptap-node/media-node/media-node.scss"
import "@/components/tiptap-node/paragraph-node/paragraph-node.scss"
import "katex/dist/katex.min.css"
import "./editor.scss"

interface TiptapRendererProps {
  content: string
  className?: string
}

export function TiptapRenderer({ content, className }: TiptapRendererProps) {
  const editor = useEditor({
    immediatelyRender: false,
    editable: false,
    textDirection: "auto",
    contentType: "markdown",
    extensions: rendererExtensions,
    editorProps: {
      attributes: {
        tabindex: "-1",
      },
    },
  })

  useEffect(() => {
    if (editor) {
      const id = setTimeout(() => {
        editor.commands.setContent(content, { contentType: "markdown" })
      }, 0)
      return () => clearTimeout(id)
    }
  }, [editor, content])

  return (
    <div className={className}>
      <EditorContent editor={editor} className="tiptap-renderer-content" />
    </div>
  )
}
