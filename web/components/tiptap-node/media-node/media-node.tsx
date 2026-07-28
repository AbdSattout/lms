"use client"

import type { MediaItemShape } from "@/components/cards/media-card"
import { LoaderIcon } from "@/components/tiptap-icons/loader-icon"
import {
  Attachment,
  AttachmentContent,
  AttachmentDescription,
  AttachmentMedia,
  AttachmentTitle,
  AttachmentTrigger,
} from "@/components/ui/attachment"
import {
  getCourseMediaByIdAction,
  getPostMediaByIdAction,
} from "@/lib/actions/media"
import type { NodeViewProps } from "@tiptap/react"
import { NodeViewWrapper } from "@tiptap/react"
import { FileTextIcon } from "lucide-react"
import { useEffect, useState } from "react"

function formatSize(bytes?: number): string {
  if (!bytes) return ""
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

export function MediaNodeComponent({ node, editor }: NodeViewProps) {
  const { organizationId, courseId, mediaId } = node.attrs as {
    organizationId: number | null
    courseId: number | null
    mediaId: number | null
  }
  const [media, setMedia] = useState<MediaItemShape | null>(null)
  const [loading, setLoading] = useState(!!mediaId && !!organizationId)
  const [error, setError] = useState(!mediaId || !organizationId)

  useEffect(() => {
    if (mediaId && organizationId) {
      const promise = courseId
        ? getCourseMediaByIdAction(organizationId, courseId, mediaId)
        : getPostMediaByIdAction(organizationId, mediaId)

      promise.then((result) => {
        if (result) {
          setMedia(result)
        } else {
          setError(true)
        }
        setLoading(false)
      })
    }
  }, [organizationId, courseId, mediaId])

  return (
    <NodeViewWrapper
      className="rounded-3xl"
      data-type="media"
      data-media-id={mediaId}
      draggable={editor.isEditable}
    >
      {loading && (
        <Attachment state="processing" orientation="horizontal" size="default">
          <AttachmentMedia variant="icon">
            <LoaderIcon className="animate-spin" />
          </AttachmentMedia>
          <AttachmentContent>
            <AttachmentTitle>Loading media...</AttachmentTitle>
          </AttachmentContent>
        </Attachment>
      )}

      {error && (
        <Attachment state="error" orientation="horizontal" size="default">
          <AttachmentMedia variant="icon">
            <FileTextIcon />
          </AttachmentMedia>
          <AttachmentContent>
            <AttachmentTitle>Failed to load media</AttachmentTitle>
          </AttachmentContent>
        </Attachment>
      )}

      {!loading && !error && media?.type === "IMAGE" && (
        <figure className="not-prose">
          {editor.isEditable ? (
            <a
              href={media.url}
              download={media.name}
              target="_blank"
              rel="noreferrer"
            >
              <img
                src={media.url}
                alt={media.name}
                className="w-full rounded-3xl border object-cover"
              />
            </a>
          ) : (
            <img
              src={media.url}
              alt={media.name}
              className="w-full rounded-3xl border object-cover"
            />
          )}
        </figure>
      )}

      {!loading && !error && media?.type === "VIDEO" && (
        <figure className="not-prose">
          {editor.isEditable ? (
            <a
              href={media.url}
              download={media.name}
              target="_blank"
              rel="noreferrer"
            >
              <video
                src={media.url}
                controls
                className="w-full rounded-3xl border"
              >
                Your browser does not support the video element.
              </video>
            </a>
          ) : (
            <video src={media.url} className="w-full rounded-3xl border" />
          )}
        </figure>
      )}

      {!loading && !error && media?.type === "FILE" && (
        <Attachment state="done" orientation="horizontal" size="default">
          {editor.isEditable && (
            <AttachmentTrigger
              render={
                <a
                  href={media.url}
                  download={media.name}
                  target="_blank"
                  rel="noreferrer"
                />
              }
            />
          )}
          <AttachmentMedia variant="icon">
            <FileTextIcon className="size-4" />
          </AttachmentMedia>
          <AttachmentContent>
            <AttachmentTitle>{media.name}</AttachmentTitle>
            <AttachmentDescription>
              {formatSize(media.sizeBytes)}
            </AttachmentDescription>
          </AttachmentContent>
        </Attachment>
      )}
    </NodeViewWrapper>
  )
}
