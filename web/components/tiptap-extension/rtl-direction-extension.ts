"use no memo"

import { Extension } from "@tiptap/core"
import { Plugin, PluginKey } from "@tiptap/pm/state"
import { Decoration, DecorationSet } from "@tiptap/pm/view"

const RTL_NODE_TYPES = [
  "bulletList",
  "orderedList",
  "listItem",
  "taskList",
  "taskItem",
  "blockquote",
]

function hasRtlText(text: string): boolean {
  return /[\u0591-\u07FF\uFB1D-\uFDFF\uFE70-\uFEFC]/.test(text)
}

export const RtlDirection = Extension.create({
  name: "rtlDirection",

  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("rtlDirection"),
        state: {
          init() {
            return DecorationSet.empty
          },
          apply(tr, value) {
            if (!tr.docChanged) return value

            const decorations: Decoration[] = []

            tr.doc.descendants((node, pos) => {
              if (RTL_NODE_TYPES.includes(node.type.name)) {
                if (hasRtlText(node.textContent)) {
                  decorations.push(
                    Decoration.node(pos, pos + node.nodeSize, {
                      dir: "rtl",
                    })
                  )
                }
              }
            })

            return DecorationSet.create(tr.doc, decorations)
          },
        },
        props: {
          decorations(state) {
            return this.getState(state)
          },
        },
      }),
    ]
  },
})
