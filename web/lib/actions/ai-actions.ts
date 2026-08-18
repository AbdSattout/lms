"use server"

import { transformText } from "@/lib/api/ai"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"

export async function transformTextAction(
  text: string,
  action: AiTextAction,
  tone?: AiTextTone
) {
  try {
    const response = await transformText.post({
      text,
      action,
      tone: action === "CHANGE_TONE" ? tone : undefined,
    })
    return { result: response.result }
  } catch (error) {
    throw new Error(
      error instanceof Error ? error.message : "Failed to process text"
    )
  }
}
