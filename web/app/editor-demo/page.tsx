"use client"

import { Editor } from "@/components/editor"
import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import { useState } from "react"

export default function EditorDemoPage() {
  const [markdown, setMarkdown] = useState("")

  return (
    <div className="flex min-h-dvh items-center justify-center p-8">
      <Dialog>
        <DialogTrigger render={<Button>Open Editor</Button>} />
        <DialogContent className="flex max-h-[90dvh] max-w-3xl flex-col gap-4">
          <DialogHeader>
            <DialogTitle>Editor Demo</DialogTitle>
          </DialogHeader>
          <div className="flex min-h-0 flex-1 flex-col overflow-hidden rounded-2xl border">
            <Editor onChange={setMarkdown} />
          </div>

          {markdown && (
            <details className="group">
              <summary className="cursor-pointer text-sm font-medium text-muted-foreground hover:text-foreground">
                Markdown Preview
              </summary>
              <pre className="mt-2 max-h-48 overflow-auto rounded-lg bg-muted p-4 text-xs">
                {markdown}
              </pre>
            </details>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
