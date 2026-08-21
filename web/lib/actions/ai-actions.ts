"use server"

import { SubscriptionLimitError } from "@/lib/api/backend"
import { transformText } from "@/lib/api/ai"
import type { AiTextAction, AiTextTone } from "@/lib/api/types"

export async function transformTextAction(
  text: string,
  action: AiTextAction,
  tone?: AiTextTone
): Promise<{ result?: string; limitReached?: boolean }> {
  try {
    const response = await transformText.post({
      text,
      action,
      tone: action === "CHANGE_TONE" ? tone : undefined,
    })
    return { result: response.result }
  } catch (error) {
    if (error instanceof SubscriptionLimitError) {
      return { limitReached: true }
    }
    return {}
  }
}
