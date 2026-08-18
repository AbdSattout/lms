import {
  MessageSquareText,
  FileText,
  UserRound,
  Building2,
  BookOpen,
} from "lucide-react"

import type { ReportTargetType } from "@/lib/api/types"

const config: Record<
  ReportTargetType,
  {
    label: string
    icon: typeof FileText
  }
> = {
  POST: {
    label: "منشور",
    icon: FileText,
  },
  COMMENT: {
    label: "تعليق",
    icon: MessageSquareText,
  },
  USER: {
    label: "مستخدم",
    icon: UserRound,
  },
  ORGANIZATION: {
    label: "منظمة",
    icon: Building2,
  },
  COURSE: {
    label: "دورة",
    icon: BookOpen,
  },
}

export function ReportTargetLabel({
  targetType,
}: {
  targetType: ReportTargetType
}) {
  const item = config[targetType]
  const Icon = item.icon

  return (
    <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-muted-foreground">
      <Icon className="h-3.5 w-3.5" />
      {item.label}
    </span>
  )
}
