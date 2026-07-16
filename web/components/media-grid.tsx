"use client"

import { MediaCard, type MediaItemShape } from "@/components/cards/media-card"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { ImageIcon } from "lucide-react"

interface MediaGridProps<T extends MediaItemShape> {
  items: T[]
  onSelect?: (item: T) => void
  onDelete?: (item: T) => void
  onEditName?: (item: T) => void
  onReplaceFile?: (item: T) => void
  empty?: React.ReactNode
}

export function MediaGrid<T extends MediaItemShape>({
  items,
  onSelect,
  onDelete,
  onEditName,
  onReplaceFile,
  empty,
}: MediaGridProps<T>) {
  if (items.length === 0) {
    return (
      empty ?? (
        <Empty>
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <ImageIcon />
            </EmptyMedia>
            <EmptyTitle>لا توجد وسائط</EmptyTitle>
          </EmptyHeader>
          <EmptyContent>لم يتم إضافة وسائط بعد.</EmptyContent>
        </Empty>
      )
    )
  }

  return (
    <div className="@container">
      <div className="grid grid-cols-1 gap-4 @sm:grid-cols-2 @lg:grid-cols-3 @xl:grid-cols-4">
        {items.map((item) => (
          <MediaCard
            key={item.id}
            media={item}
            onSelect={onSelect}
            onDelete={onDelete}
            onEditName={onEditName}
            onReplaceFile={onReplaceFile}
          />
        ))}
      </div>
    </div>
  )
}
