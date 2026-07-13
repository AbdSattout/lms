// components/tiptap-ui/ai-tools/types.ts
import type { AiTextAction, AiTextTone } from "@/lib/api/types"

export interface AiActionOption {
  value: AiTextAction
  label: string
  description: string
  requiresTone?: boolean
}

export interface AiToneOption {
  value: AiTextTone
  label: string
}

export const AI_ACTIONS: AiActionOption[] = [
  {
    value: "PROOFREAD",
    label: "Proofread",
    description: "Check grammar and spelling",
  },
  {
    value: "REWRITE",
    label: "Rewrite",
    description: "Rephrase the selected text",
  },
  {
    value: "SUMMARIZE",
    label: "Summarize",
    description: "Create a concise summary",
  },
  {
    value: "EXPAND",
    label: "Expand",
    description: "Add more detail and context",
  },
  {
    value: "CHANGE_TONE",
    label: "Change Tone",
    description: "Adjust the writing tone",
    requiresTone: true,
  },
  {
    value: "WRITE",
    label: "Write",
    description: "Generate new content",
  },
]

export const AI_TONES: AiToneOption[] = [
  { value: "PROFESSIONAL", label: "Professional" },
  { value: "FRIENDLY", label: "Friendly" },
  { value: "SIMPLE", label: "Simple" },
  { value: "ACADEMIC", label: "Academic" },
  { value: "MOTIVATIONAL", label: "Motivational" },
]
