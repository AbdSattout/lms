"use client"

import { useEffect, useState } from "react"
import type { NodeViewProps } from "@tiptap/react"
import { NodeViewWrapper } from "@tiptap/react"
import { LoaderIcon } from "@/components/tiptap-icons/loader-icon"
import {
  Attachment,
  AttachmentContent,
  AttachmentDescription,
  AttachmentMedia,
  AttachmentTitle,
  AttachmentTrigger,
} from "@/components/ui/attachment"
import type { MediaItemShape } from "@/components/cards/media-card"
import {
  getPostMediaByIdAction,
  getCourseMediaByIdAction,
} from "@/lib/actions/media"
import { FileTextIcon } from "lucide-react"

function formatSize(bytes?: number): string {
  if (!bytes) return ""
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

export function MediaNodeComponent({ node }: NodeViewProps) {
  const { orgSlug, courseSlug, mediaId } = node.attrs as {
    orgSlug: string | null
    courseSlug: string | null
    mediaId: number | null
  }
  const [media, setMedia] = useState<MediaItemShape | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)

  useEffect(() => {
    if (!mediaId || !orgSlug) {
      setLoading(false)
      setError(true)
      return
    }

    setLoading(true)
    setError(false)

    const promise = courseSlug
      ? getCourseMediaByIdAction(orgSlug, courseSlug, mediaId)
      : getPostMediaByIdAction(orgSlug, mediaId)

    promise.then((result) => {
      if (result) {
        setMedia(result)
        setLoading(false)
      } else {
        setError(true)
        setLoading(false)
      }
    })
  }, [orgSlug, courseSlug, mediaId])

  return (
    <NodeViewWrapper className="rounded-3xl" data-type="media" data-media-id={mediaId}>
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
          <a href={media.url} download={media.name} target="_blank" rel="noreferrer">
            <img
              src={media.url}
              alt={media.name}
              className="w-full rounded-3xl border object-cover"
            />
          </a>
        </figure>
      )}

      {!loading && !error && media?.type === "VIDEO" && (
        <figure className="not-prose">
          <video
            src={media.url}
            controls
            className="w-full rounded-3xl border"
          >
            Your browser does not support the video element.
          </video>
        </figure>
      )}

      {!loading && !error && media?.type === "FILE" && (
        <Attachment state="done" orientation="horizontal" size="default">
          <AttachmentTrigger
            render={<a href={media.url} download={media.name} target="_blank" rel="noreferrer" />}
          />
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
