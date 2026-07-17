"use no memo"
"use client"

import { EditorContent, EditorContext, useEditor } from "@tiptap/react"
import { useEffect, useRef, useState } from "react"

import { RtlDirection } from "@/components/tiptap-extension/rtl-direction-extension"
import { Button } from "@/components/tiptap-ui-primitive/button"
import { Spacer } from "@/components/tiptap-ui-primitive/spacer"
import {
  Toolbar,
  ToolbarGroup,
  ToolbarSeparator,
} from "@/components/tiptap-ui-primitive/toolbar"
import { TaskItem, TaskList } from "@tiptap/extension-list"
import { Typography } from "@tiptap/extension-typography"
import { Selection } from "@tiptap/extensions"
import { Markdown } from "@tiptap/markdown"
import { StarterKit } from "@tiptap/starter-kit"

import "@/components/tiptap-node/blockquote-node/blockquote-node.scss"
import "@/components/tiptap-node/code-block-node/code-block-node.scss"
import "@/components/tiptap-node/heading-node/heading-node.scss"
import { HorizontalRule } from "@/components/tiptap-node/horizontal-rule-node/horizontal-rule-node-extension"
import "@/components/tiptap-node/horizontal-rule-node/horizontal-rule-node.scss"
import "@/components/tiptap-node/list-node/list-node.scss"
import { MediaNode } from "@/components/tiptap-node/media-node"
import "@/components/tiptap-node/media-node/media-node.scss"
import "@/components/tiptap-node/paragraph-node/paragraph-node.scss"

import { BlockquoteButton } from "@/components/tiptap-ui/blockquote-button"
import { CodeBlockButton } from "@/components/tiptap-ui/code-block-button"
import { HeadingDropdownMenu } from "@/components/tiptap-ui/heading-dropdown-menu"
import {
  LinkButton,
  LinkContent,
  LinkPopover,
} from "@/components/tiptap-ui/link-popover"
import { ListDropdownMenu } from "@/components/tiptap-ui/list-dropdown-menu"
import { MarkButton } from "@/components/tiptap-ui/mark-button"
import { MediaButton } from "@/components/tiptap-ui/media-button"

import { ArrowRightIcon } from "@/components/tiptap-icons/arrow-right-icon"
import { LinkIcon } from "@/components/tiptap-icons/link-icon"

import { useAiTools } from "@/hooks/use-ai-tools"
import { useIsBreakpoint } from "@/hooks/use-is-breakpoint"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"
import { toast } from "sonner"

import "./editor.scss"
import { AiToolsDropdown } from "./tiptap-ui/ai-tool-dropdown/ai-tool-dropdown"

const MainToolbarContent = ({
  onLinkClick,
  isMobile,
  onAiAction,
  isAiLoading,
  aiError,
  onClearAiError,
  orgSlug,
  course,
}: {
  onLinkClick: () => void
  isMobile: boolean
  onAiAction: (action: AiTextAction, tone?: AiTextTone) => void
  isAiLoading?: boolean
  aiError?: string | null
  onClearAiError?: () => void
  orgSlug?: string
  course?: import("@/lib/api/types").CourseResponse
}) => {
  return (
    <>
      <Spacer />

      <ToolbarGroup>
        <AiToolsDropdown
          onAction={onAiAction}
          isLoading={isAiLoading}
          error={aiError}
          onClearError={onClearAiError}
        />
      </ToolbarGroup>
      <ToolbarSeparator />

      <ToolbarGroup>
        <HeadingDropdownMenu
          modal={false}
          levels={[1, 2, 3, 4]}
          tooltip="أنماط العناوين"
        />
        <ListDropdownMenu
          modal={false}
          types={["bulletList", "orderedList", "taskList"]}
          tooltip="القوائم"
        />
        <BlockquoteButton />
        <CodeBlockButton />
      </ToolbarGroup>

      <ToolbarSeparator />

      <ToolbarGroup>
        <MarkButton type="bold" />
        <MarkButton type="italic" />
        <MarkButton type="strike" />
        <MarkButton type="code" />
        <MarkButton type="underline" />
        {!isMobile ? <LinkPopover /> : <LinkButton onClick={onLinkClick} />}
        <MediaButton orgSlug={orgSlug} course={course} />
      </ToolbarGroup>

      <Spacer />
    </>
  )
}

const MobileToolbarContent = ({
  onBack,
}: {
  onBack: () => void
  onAiAction: (action: AiTextAction, tone?: AiTextTone) => void
  isAiLoading?: boolean
  aiError?: string | null
  onClearAiError?: () => void
}) => (
  <>
    <ToolbarGroup>
      <Button variant="ghost" onClick={onBack}>
        <ArrowRightIcon className="tiptap-button-icon" />
        <LinkIcon className="tiptap-button-icon" />
      </Button>
    </ToolbarGroup>

    <ToolbarSeparator />

    <LinkContent />
  </>
)

interface EditorProps {
  onChange?: (markdown: string) => void
  content?: string
  orgSlug?: string
  course?: import("@/lib/api/types").CourseResponse
}

export function Editor({ onChange, content, orgSlug, course }: EditorProps) {
  const isMobile = useIsBreakpoint()
  const [showLink, setShowLink] = useState(false)
  const mobileView = isMobile ? (showLink ? "link" : "main") : "main"
  const toolbarRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = toolbarRef.current
    if (!el) return
    const onWheel = (e: WheelEvent) => {
      if (Math.abs(e.deltaX) < Math.abs(e.deltaY)) {
        el.scrollLeft += e.deltaY
        e.preventDefault()
      }
    }
    el.addEventListener("wheel", onWheel, { passive: false })
    return () => el.removeEventListener("wheel", onWheel)
  }, [])

  const editor = useEditor({
    immediatelyRender: false,
    textDirection: "auto",
    contentType: "markdown",
    autofocus: true,
    editorProps: {
      attributes: {
        autocomplete: "off",
        autocorrect: "off",
        autocapitalize: "off",
        "aria-label": "Main content area, start typing to enter text.",
        class: "simple-editor",
      },
    },
    extensions: [
      StarterKit.configure({
        horizontalRule: false,
        link: {
          openOnClick: false,
          enableClickSelection: true,
        },
      }),
      HorizontalRule,
      TaskList,
      TaskItem.configure({ nested: true }),
      RtlDirection,
      Typography,
      Selection,
      MediaNode,
      Markdown,
    ],
    onUpdate: ({ editor }) => {
      onChange?.(editor.getMarkdown())
    },
  })

  // AI tools hook
  const { isLoading, error, handleAiAction, clearError } = useAiTools({
    editor,
  })

  // Tracks active loading cycles to notify successful completion
  const wasLoading = useRef(false)
  useEffect(() => {
    if (isLoading) {
      wasLoading.current = true
    } else if (wasLoading.current && !isLoading) {
      wasLoading.current = false
      if (!error) {
        toast.success(<span dir="rtl">تم تحديث المحتوى بنجاح!</span>)
      }
    }
  }, [isLoading, error])

  useEffect(() => {
    if (!editor || content === undefined) return
    editor.commands.setContent(content, {
      emitUpdate: false,
      contentType: "markdown",
    })
  }, [editor, content])

  return (
    <div className="editor-wrapper">
      <EditorContext.Provider value={{ editor }}>
        <Toolbar ref={toolbarRef}>
          {mobileView === "main" ? (
            <MainToolbarContent
              onLinkClick={() => setShowLink(true)}
              isMobile={isMobile}
              onAiAction={handleAiAction}
              isAiLoading={isLoading}
              aiError={error}
              onClearAiError={clearError}
              orgSlug={orgSlug}
              course={course}
            />
          ) : (
            <MobileToolbarContent
              onBack={() => setShowLink(false)}
              onAiAction={handleAiAction}
              isAiLoading={isLoading}
              aiError={error}
              onClearAiError={clearError}
            />
          )}
        </Toolbar>

        <EditorContent
          editor={editor}
          role="presentation"
          className="simple-editor-content"
        />
      </EditorContext.Provider>
    </div>
  )
}
