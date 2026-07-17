"use client"

import { useState, useCallback, forwardRef } from "react"
import type { Editor } from "@tiptap/react"
import { useTiptapEditor } from "@/hooks/use-tiptap-editor"
import { Button } from "@/components/tiptap-ui-primitive/button"
import { ImagePlusIcon } from "@/components/tiptap-icons/image-plus-icon"
import { MediaLibrary } from "@/components/media-library"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import type { MediaItemShape } from "@/components/cards/media-card"
import type { CourseResponse } from "@/lib/api/types"
import { useMedia } from "./use-media"

export interface MediaButtonProps {
  editor?: Editor | null
  hideWhenUnavailable?: boolean
  onInserted?: () => void
  orgSlug?: string
  course?: CourseResponse
}

export const MediaButton = forwardRef<HTMLButtonElement, MediaButtonProps>(
  (
    {
      editor: providedEditor,
      hideWhenUnavailable = false,
      onInserted,
      orgSlug,
      course,
    },
    ref,
  ) => {
    const { editor } = useTiptapEditor(providedEditor)
    const { isVisible, canInsert, handleMediaInsert } = useMedia({
      editor,
      hideWhenUnavailable,
      onInserted,
      orgSlug,
      courseSlug: course?.slug ?? null,
    })
    const [open, setOpen] = useState(false)

    const handleSelect = useCallback(
      (item: MediaItemShape) => {
        handleMediaInsert(item.id)
        setOpen(false)
      },
      [handleMediaInsert],
    )

    if (!isVisible || !editor) return null

    return (
      <>
        <Button
          ref={ref}
          type="button"
          variant="ghost"
          role="button"
          tabIndex={-1}
          disabled={!canInsert}
          data-disabled={!canInsert}
          aria-label="Add media"
          tooltip="Add media"
          onClick={() => setOpen(true)}
        >
          <ImagePlusIcon className="tiptap-button-icon" />
        </Button>

        <Dialog open={open} onOpenChange={setOpen}>
          <DialogContent className="flex max-h-[85dvh] max-w-5xl flex-col gap-4">
            <DialogHeader>
              <DialogTitle>Select media</DialogTitle>
            </DialogHeader>
            {orgSlug && (
              <MediaLibrary
                orgSlug={orgSlug}
                course={course}
                title="Media library"
                dialog
                open={open}
                onOpenChange={setOpen}
                onSelect={handleSelect}
              />
            )}
          </DialogContent>
        </Dialog>
      </>
    )
  },
)

MediaButton.displayName = "MediaButton"
