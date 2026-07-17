"use client"

import { Button } from "@/components/tiptap-ui-primitive/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuPortal,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuTrigger,
} from "@/components/tiptap-ui-primitive/dropdown-menu"
import { useEffect, useRef, useState } from "react"

import { AlertCircleIcon } from "@/components/tiptap-icons/alert-icon"
import { ChevronDownIcon } from "@/components/tiptap-icons/chevron-down-icon"
import { LoaderIcon } from "@/components/tiptap-icons/loader-icon"
import { SparklesIcon } from "@/components/tiptap-icons/sparkles-icon"
import { AI_ACTIONS, AI_TONES } from "@/lib/ai-tools-types"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"
import { cn } from "@/lib/utils"
import { toast } from "sonner"
import "./ai-tool-dropdown.scss"

// Vector Line Icons for Actions
function SpellCheckIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="m16 16 2 2 4-4" />
      <path d="M12 20H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8" />
      <path d="M6 6h8" />
      <path d="M6 10h8" />
      <path d="M6 14h4" />
    </svg>
  )
}

function RefreshIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
      <path d="M3 3v5h5" />
      <path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16" />
      <path d="M16 16h5v5" />
    </svg>
  )
}

function SummarizeIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M4 6h16" />
      <path d="M4 12h10" />
      <path d="M4 18h14" />
    </svg>
  )
}

function ExpandIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M15 3h6v6" />
      <path d="M9 21H3v-6" />
      <path d="M21 3l-7 7" />
      <path d="M3 21l7-7" />
    </svg>
  )
}

function SlidersIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <line x1="4" x2="4" y1="21" y2="14" />
      <line x1="4" x2="4" y1="10" y2="3" />
      <line x1="12" x2="12" y1="21" y2="12" />
      <line x1="12" x2="12" y1="8" y2="3" />
      <line x1="20" x2="20" y1="21" y2="16" />
      <line x1="20" x2="20" y1="12" y2="3" />
      <line x1="2" x2="6" y1="14" y2="14" />
      <line x1="10" x2="14" y1="8" y2="8" />
      <line x1="18" x2="22" y1="16" y2="16" />
    </svg>
  )
}

function WriteIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275Z" />
      <path d="m5 3 1 2.5L8.5 6 6 7 5 9.5 4 7 1.5 6 4 5.5Z" />
    </svg>
  )
}

// Vector Line Icons for Tones
function BriefcaseIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16" />
      <rect width="20" height="14" x="2" y="6" rx="2" />
    </svg>
  )
}

function SmileIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <circle cx="12" cy="12" r="10" />
      <path d="M8 14s1.5 2 4 2 4-2 4-2" />
      <line x1="9" x2="9.01" y1="9" y2="9" />
      <line x1="15" x2="15.01" y1="9" y2="9" />
    </svg>
  )
}

function LightbulbIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .5 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5" />
      <path d="M9 18h6" />
      <path d="M10 22h4" />
    </svg>
  )
}

function GraduationCapIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d="M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z" />
      <path d="M6 12v5c0 2 2 3 6 3s6-1 6-3v-5" />
    </svg>
  )
}

function ZapIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
    </svg>
  )
}

const ACTION_ICONS: Record<
  AiTextAction,
  React.ComponentType<React.SVGProps<SVGSVGElement>>
> = {
  PROOFREAD: SpellCheckIcon,
  REWRITE: RefreshIcon,
  SUMMARIZE: SummarizeIcon,
  EXPAND: ExpandIcon,
  CHANGE_TONE: SlidersIcon,
  WRITE: WriteIcon,
}

const TONE_ICONS: Record<
  AiTextTone,
  React.ComponentType<React.SVGProps<SVGSVGElement>>
> = {
  PROFESSIONAL: BriefcaseIcon,
  FRIENDLY: SmileIcon,
  SIMPLE: LightbulbIcon,
  ACADEMIC: GraduationCapIcon,
  MOTIVATIONAL: ZapIcon,
}

interface AiToolsDropdownProps {
  onAction: (action: AiTextAction, tone?: AiTextTone) => void
  isLoading?: boolean
  error?: string | null
  onClearError?: () => void
}

export function AiToolsDropdown({
  onAction,
  isLoading,
  error,
  onClearError,
}: AiToolsDropdownProps) {
  const [open, setOpen] = useState(false)
  const triggerRef = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (error) {
      toast.error(error)
      onClearError?.()
    }
  }, [error, onClearError])

  const handleAction = (action: AiTextAction, tone?: AiTextTone) => {
    onAction(action, tone)
    setOpen(false)
  }

  return (
    <DropdownMenu open={open} onOpenChange={(newOpen) => !isLoading && setOpen(newOpen)}>
      <DropdownMenuTrigger asChild disabled={isLoading}>
        <Button
          ref={triggerRef}
          variant="ghost"
          className={cn(
            "ai-tools-trigger",
            isLoading && "ai-tools-trigger--loading",
            error && "ai-tools-trigger--error"
          )}
          disabled={isLoading}
        >
          {isLoading ? (
            <LoaderIcon className="tiptap-button-icon animate-spin" />
          ) : error ? (
            <AlertCircleIcon className="tiptap-button-icon" />
          ) : (
            <SparklesIcon className="tiptap-button-icon" />
          )}
          <ChevronDownIcon className="tiptap-button-dropdown-small" />
          <span className="sr-only">AI Tools</span>
        </Button>
      </DropdownMenuTrigger>

      <DropdownMenuContent
        className="ai-tools-content"
        align="start"
        sideOffset={8}
      >
        <DropdownMenuSeparator />

        {AI_ACTIONS.map((action) => {
          const ActionIcon = ACTION_ICONS[action.value] || SparklesIcon

          if (action.requiresTone) {
            return (
              <DropdownMenuSub key={action.value}>
                <DropdownMenuSubTrigger className="ai-tools-item">
                  <div className="ai-tools-item-content-wrapper">
                    <div className="ai-tools-item-icon-container">
                      <ActionIcon className="ai-tools-item-icon" />
                    </div>
                    <div className="ai-tools-item-content">
                      <span className="ai-tools-item-label">
                        {action.label}
                      </span>
                      <span className="ai-tools-item-description">
                        {action.description}
                      </span>
                    </div>
                  </div>
                </DropdownMenuSubTrigger>

                <DropdownMenuPortal>
                  <DropdownMenuSubContent className="ai-tools-subcontent">
                    <DropdownMenuLabel className="ai-tools-label">
                      اختر النبرة
                    </DropdownMenuLabel>
                    <DropdownMenuSeparator />

                    {AI_TONES.map((tone) => {
                      const ToneIcon = TONE_ICONS[tone.value] || SparklesIcon
                      return (
                        <DropdownMenuItem
                          key={tone.value}
                          className="ai-tools-item"
                          onSelect={(e) => {
                            e.preventDefault()
                            handleAction(action.value, tone.value)
                          }}
                        >
                          <div className="ai-tools-item-content-wrapper">
                            <div className="ai-tools-item-icon-container">
                              <ToneIcon className="ai-tools-item-icon" />
                            </div>
                            <div className="ai-tools-item-content">
                              <span className="ai-tools-item-label">
                                {tone.label}
                              </span>
                            </div>
                          </div>
                        </DropdownMenuItem>
                      )
                    })}
                  </DropdownMenuSubContent>
                </DropdownMenuPortal>
              </DropdownMenuSub>
            )
          }

          return (
            <DropdownMenuItem
              key={action.value}
              className="ai-tools-item"
              onSelect={(e) => {
                e.preventDefault()
                handleAction(action.value)
              }}
            >
              <div className="ai-tools-item-content-wrapper">
                <div className="ai-tools-item-icon-container">
                  <ActionIcon className="ai-tools-item-icon" />
                </div>
                <div className="ai-tools-item-content">
                  <span className="ai-tools-item-label">{action.label}</span>
                  <span className="ai-tools-item-description">
                    {action.description}
                  </span>
                </div>
              </div>
            </DropdownMenuItem>
          )
        })}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
