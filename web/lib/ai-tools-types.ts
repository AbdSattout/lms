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
    label: "تدقيق ومراجعة",
    description: "التحقق من القواعد النحوية والإملائية",
  },
  {
    value: "REWRITE",
    label: "إعادة كتابة",
    description: "إعادة صياغة النص المحدد بشكل أفضل",
  },
  {
    value: "SUMMARIZE",
    label: "تلخيص النص",
    description: "إنشاء ملخص موجز ومختصر للنص",
  },
  {
    value: "EXPAND",
    label: "توسيع النص",
    description: "إضافة المزيد من التفاصيل والسياق المناسب",
  },
  {
    value: "CHANGE_TONE",
    label: "تغيير النبرة",
    description: "تعديل أسلوب ونبرة كتابة النص",
    requiresTone: true,
  },
  {
    value: "WRITE",
    label: "توليد نص",
    description: "إنشاء محتوى نصي جديد بالكامل",
  },
]

export const AI_TONES: AiToneOption[] = [
  { value: "PROFESSIONAL", label: "مهني ورسمي" },
  { value: "FRIENDLY", label: "ودود ولطيف" },
  { value: "SIMPLE", label: "مبسط وسهل" },
  { value: "ACADEMIC", label: "أكاديمي وعلمي" },
  { value: "MOTIVATIONAL", label: "حماسي وتحفيزي" },
]
