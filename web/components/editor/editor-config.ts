import type { Extensions } from "@tiptap/core"
import { TaskItem, TaskList } from "@tiptap/extension-list"
import { Mathematics } from "@tiptap/extension-mathematics"
import { Typography } from "@tiptap/extension-typography"
import { Selection } from "@tiptap/extensions"
import { Markdown } from "@tiptap/markdown"
import { StarterKit } from "@tiptap/starter-kit"

import { RtlDirection } from "@/components/tiptap-extension/rtl-direction-extension"
import { HorizontalRule } from "@/components/tiptap-node/horizontal-rule-node/horizontal-rule-node-extension"
import { MediaNode } from "@/components/tiptap-node/media-node"

export const editorExtensions: Extensions = [
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
  Mathematics.configure({
    katexOptions: {
      throwOnError: false,
    },
  }),
]

export const rendererExtensions: Extensions = [
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
  MediaNode.extend({ selectable: false }),
  Markdown,
  Mathematics.configure({
    katexOptions: {
      throwOnError: false,
    },
  }),
]
