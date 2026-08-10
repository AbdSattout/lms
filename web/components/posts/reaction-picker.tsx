"use client"

import { useState } from "react"
import { Heart } from "lucide-react"
import type { PostReactionType } from "@/lib/api/types"

const REACTIONS: {
  type: PostReactionType
  emoji: string
  label: string
}[] = [
  { type: "LIKE", emoji: "👍", label: "إعجاب" },
  { type: "LOVE", emoji: "❤️", label: "حب" },
  { type: "SUPPORT", emoji: "🤝", label: "دعم" },
  { type: "CELEBRATE", emoji: "🎉", label: "احتفال" },
  { type: "INSIGHTFUL", emoji: "💡", label: "مفيد" },
]

interface ReactionPickerProps {
  onReactionSelect: (type: PostReactionType) => void
  currentReaction?: PostReactionType
  onRemoveReaction?: () => void
  size?: "sm" | "md"
}

export function ReactionPicker({
  onReactionSelect,
  currentReaction,
  onRemoveReaction,
  size = "md",
}: ReactionPickerProps) {
  const [showPicker, setShowPicker] = useState(false)

  const currentReactionData = REACTIONS.find(
    (reaction) => reaction.type === currentReaction
  )

  function handleMainClick() {
    if (currentReaction && onRemoveReaction) {
      onRemoveReaction()
      return
    }

    onReactionSelect("LIKE")
  }
  function handleReactionClick(type: PostReactionType) {
    if (currentReaction === type && onRemoveReaction) {
      onRemoveReaction()
    } else {
      onReactionSelect(type)
    }

    setShowPicker(false)
  }

  return (
    <div
      className="relative inline-flex"
      onMouseEnter={() => setShowPicker(true)}
      onMouseLeave={() => setShowPicker(false)}
    >
      <button
        type="button"
        onClick={handleMainClick}
        className={`inline-flex cursor-pointer items-center gap-1.5 transition-colors ${
          size === "sm" ? "text-xs" : "text-sm"
        } ${
          currentReaction
            ? "text-red-500 hover:text-red-600"
            : "text-muted-foreground hover:text-red-500"
        }`}
        aria-label={currentReactionData?.label ?? "إعجاب"}
      >
        {currentReactionData ? (
          <span className={size === "sm" ? "text-base" : "text-lg"}>
            {currentReactionData.emoji}
          </span>
        ) : (
          <Heart
            className={size === "sm" ? "h-4 w-4" : "h-5 w-5"}
            fill={currentReaction ? "currentColor" : "none"}
          />
        )}
      </button>

      {showPicker && (
        <div
          className="absolute bottom-full z-50"
          onMouseEnter={() => setShowPicker(true)}
        >
          <div className="flex gap-1 rounded-full bg-popover p-1.5 shadow-lg ring-1 ring-border">
            {REACTIONS.map((reaction) => (
              <button
                key={reaction.type}
                type="button"
                onClick={() => handleReactionClick(reaction.type)}
                className={`cursor-pointer rounded-full p-1.5 text-lg transition-transform hover:scale-125 hover:bg-muted ${
                  currentReaction === reaction.type
                    ? "scale-110 bg-red-100 dark:bg-red-900/30"
                    : ""
                }`}
                title={reaction.label}
                aria-label={reaction.label}
              >
                {reaction.emoji}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
