"use client"

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import type { FileType } from "@/lib/api/types"
import { cn } from "@/lib/utils"
import {
  Download,
  EllipsisVertical,
  FileTextIcon,
  FilmIcon,
  ImageIcon,
  Pencil,
  Replace,
  Trash2,
} from "lucide-react"

export interface MediaItemShape {
  id: number
  name: string
  url: string
  type: FileType
  sizeBytes?: number
}

function formatSize(bytes?: number): string {
  if (!bytes) return ""
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

function typeLabel(type: FileType): string {
  switch (type) {
    case "IMAGE":
      return "صورة"
    case "VIDEO":
      return "فيديو"
    case "FILE":
      return "ملف"
  }
}

function MediaIcon({ type }: { type: FileType }) {
  switch (type) {
    case "IMAGE":
      return <ImageIcon className="size-8" />
    case "VIDEO":
      return <FilmIcon className="size-8" />
    case "FILE":
      return <FileTextIcon className="size-8" />
  }
}

interface MediaCardProps<T extends MediaItemShape> {
  media: T
  onSelect?: (media: T) => void
  onDelete?: (media: T) => void
  onEditName?: (media: T) => void
  onReplaceFile?: (media: T) => void
}

export function MediaCard<T extends MediaItemShape>({
  media,
  onSelect,
  onDelete,
  onEditName,
  onReplaceFile,
}: MediaCardProps<T>) {
  const isImage = media.type === "IMAGE"

  return (
    <div
      role={onSelect ? "button" : undefined}
      tabIndex={onSelect ? 0 : undefined}
      className={cn(
        "group relative overflow-hidden rounded-3xl border border-border bg-card transition-colors hover:bg-accent/50",
        onSelect && "cursor-pointer"
      )}
      onClick={onSelect ? () => onSelect(media) : undefined}
      onKeyDown={onSelect ? (e) => { if (e.key === "Enter") onSelect(media) } : undefined}
    >
      <div
        className={cn(
          "flex aspect-square items-center justify-center bg-muted",
          isImage && "bg-transparent"
        )}
      >
        {isImage ? (
          <img
            src={media.url}
            alt={media.name}
            className="h-full w-full object-cover"
          />
        ) : (
          <MediaIcon type={media.type} />
        )}
      </div>

      <div className="flex items-center gap-2 p-3">
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-medium" title={media.name}>
            {media.name}
          </p>
          <p className="text-xs text-muted-foreground">
            {typeLabel(media.type)}
            {media.sizeBytes ? ` · ${formatSize(media.sizeBytes)}` : ""}
          </p>
        </div>

        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            render={
              <button className="flex size-8 shrink-0 items-center justify-center rounded-full text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100 hover:bg-muted hover:text-foreground focus:opacity-100">
                <EllipsisVertical className="size-4" />
              </button>
            }
          />
          <DropdownMenuContent align="end">
            <DropdownMenuItem
              onClick={(e) => {
                e.stopPropagation()
                const a = document.createElement("a")
                a.href = media.url
                a.download = media.name
                a.target = "_blank"
                a.rel = "noreferrer"
                a.click()
              }}
            >
              <Download />
              تحميل
            </DropdownMenuItem>

            {onEditName && (
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation()
                  onEditName(media)
                }}
              >
                <Pencil />
                تعديل الاسم
              </DropdownMenuItem>
            )}

            {onReplaceFile && (
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation()
                  onReplaceFile(media)
                }}
              >
                <Replace />
                استبدال الملف
              </DropdownMenuItem>
            )}

            {onDelete && (
              <>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  variant="destructive"
                  onClick={(e) => {
                    e.stopPropagation()
                    onDelete(media)
                  }}
                >
                  <Trash2 />
                  حذف
                </DropdownMenuItem>
              </>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  )
}
