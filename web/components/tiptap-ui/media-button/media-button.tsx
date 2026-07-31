"use client"

import type { MediaItemShape } from "@/components/cards/media-card"
import { MediaLibrary } from "@/components/media-library"
import { ImagePlusIcon } from "@/components/tiptap-icons/image-plus-icon"
import { Button } from "@/components/tiptap-ui-primitive/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { useTiptapEditor } from "@/hooks/use-tiptap-editor"
import type { CourseResponse } from "@/lib/api/types"
import type { Editor } from "@tiptap/react"
import { forwardRef, useCallback, useState } from "react"
import { useMedia } from "./use-media"

export interface MediaButtonProps {
  editor?: Editor | null
  hideWhenUnavailable?: boolean
  onInserted?: () => void
  orgSlug?: string
  course?: CourseResponse
  organizationId?: number
  courseId?: number
}

export const MediaButton = forwardRef<HTMLButtonElement, MediaButtonProps>(
  (
    {
      editor: providedEditor,
      hideWhenUnavailable = false,
      onInserted,
      orgSlug,
      course,
      organizationId: orgIdProp,
      courseId: courseIdProp,
    },
    ref
  ) => {
    const { editor } = useTiptapEditor(providedEditor)
    const organizationId = orgIdProp ?? course?.organization.id ?? null
    const courseId = courseIdProp ?? course?.id ?? null

    const { isVisible, canInsert, handleMediaInsert } = useMedia({
      editor,
      hideWhenUnavailable,
      onInserted,
      organizationId,
      courseId,
    })
    const [open, setOpen] = useState(false)

    const handleSelect = useCallback(
      (item: MediaItemShape) => {
        handleMediaInsert(item.id)
        setOpen(false)
      },
      [handleMediaInsert]
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
          aria-label="إضافة وسائط"
          tooltip="إضافة وسائط"
          onClick={() => setOpen(true)}
        >
          <ImagePlusIcon className="tiptap-button-icon" />
        </Button>

        <Dialog open={open} onOpenChange={setOpen}>
          <DialogContent className="flex max-h-[85dvh] max-w-5xl flex-col gap-4">
            <DialogHeader>
              <DialogTitle>Select media</DialogTitle>
            </DialogHeader>
            {orgSlug && organizationId && (
              <MediaLibrary
                orgSlug={orgSlug}
                organizationId={organizationId}
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
  }
)

MediaButton.displayName = "MediaButton"
