"use no memo"

import { Extension } from "@tiptap/core"
import { Plugin, PluginKey } from "@tiptap/pm/state"

const RTL_TYPES = [
  "bulletList",
  "orderedList",
  "listItem",
  "taskList",
  "taskItem",
  "blockquote",
]

const RTL_REGEX = /[\u0591-\u07FF\uFB1D-\uFDFF\uFE70-\uFEFC]/

function hasRtlText(text: string): boolean {
  return RTL_REGEX.test(text)
}

export const RtlDirection = Extension.create({
  name: "rtlDirection",

  addGlobalAttributes() {
    return [
      {
        types: RTL_TYPES,
        attributes: {
          dir: {
            default: null,
            parseHTML: (element) => element.getAttribute("dir"),
            renderHTML: (attributes) => {
              const dir = attributes.dir as string | null
              if (!dir) return {}
              return { dir }
            },
          },
        },
      },
    ]
  },

  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("rtlDirection"),
        appendTransaction: (transactions, _oldState, newState) => {
          if (!transactions.some((tr) => tr.docChanged)) return null

          const tr = newState.tr
          let modified = false

          newState.doc.descendants((node, pos) => {
            if (RTL_TYPES.includes(node.type.name)) {
              const hasRtl = hasRtlText(node.textContent)
              const currentDir = node.attrs.dir
              if (hasRtl && currentDir !== "rtl") {
                tr.setNodeAttribute(pos, "dir", "rtl")
                modified = true
              } else if (!hasRtl && currentDir === "rtl") {
                tr.setNodeAttribute(pos, "dir", null)
                modified = true
              }
            }
          })

          return modified ? tr : null
        },
      }),
    ]
  },
})
