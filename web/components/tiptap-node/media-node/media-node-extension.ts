import { mergeAttributes, Node, ReactNodeViewRenderer } from "@tiptap/react"
import { MediaNodeComponent } from "./media-node"

declare module "@tiptap/react" {
  interface Commands<ReturnType> {
    media: {
      setMediaNode: (attrs: {
        organizationId: number
        courseId?: number | null
        mediaId: number
      }) => ReturnType
    }
  }
}

export const MediaNode = Node.create({
  name: "media",

  group: "block",

  atom: true,

  draggable: true,

  selectable: true,

  addAttributes() {
    return {
      organizationId: { default: null },
      courseId: { default: null },
      mediaId: { default: null },
    }
  },

  parseHTML() {
    return [{ tag: 'div[data-type="media"]' }]
  },

  renderHTML({ HTMLAttributes }) {
    return ["div", mergeAttributes({ "data-type": "media" }, HTMLAttributes)]
  },

  addNodeView() {
    return ReactNodeViewRenderer(MediaNodeComponent, {
      stopEvent: ({ event }) => {
        if (
          event.type === "mousedown" ||
          event.type === "drop" ||
          event.type === "copy" ||
          event.type === "cut" ||
          event.type === "paste" ||
          event.type.startsWith("drag")
        ) {
          return false
        }
        return true
      },
    })
  },

  addCommands() {
    return {
      setMediaNode:
        (attrs) =>
        ({ commands }) => {
          return commands.insertContent({
            type: this.name,
            attrs,
          })
        },
    }
  },

  parseMarkdown(token) {
    const raw = token.content as string
    const parts = raw.split("/")
    if (parts.length === 2) {
      return {
        type: "media",
        attrs: {
          organizationId: Number(parts[0]),
          courseId: null,
          mediaId: Number(parts[1]),
        },
      }
    }
    if (parts.length === 3) {
      return {
        type: "media",
        attrs: {
          organizationId: Number(parts[0]),
          courseId: Number(parts[1]),
          mediaId: Number(parts[2]),
        },
      }
    }
    return []
  },

  markdownTokenizer: {
    name: "media",
    level: "block",
    start(src) {
      return src.match(/^::media\s+\S+$/m)?.index ?? -1
    },
    tokenize(src) {
      const match = src.match(/^::media\s+(\S+)$/)
      if (!match) return undefined
      return {
        type: "media",
        raw: match[0],
        content: match[1],
      }
    },
  },

  renderMarkdown(node) {
    const { organizationId, courseId, mediaId } = node.attrs ?? {}
    if (!organizationId || !mediaId) return ""
    const path = courseId
      ? `${organizationId}/${courseId}/${mediaId}`
      : `${organizationId}/${mediaId}`
    return `::media ${path}`
  },
})
