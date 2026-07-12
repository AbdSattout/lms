import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"

interface OrgAvatarProps {
  src?: string
  name?: string
  className?: string
}

export function OrgAvatar({ src, name, className }: OrgAvatarProps) {
  return (
    <Avatar
      className={cn(
        "rounded-[22%]! *:rounded-[22%]! [&::after]:rounded-[22%]!",
        className
      )}
    >
      <AvatarImage src={src} alt={name ?? ""} />
      <AvatarFallback className="rounded-[22%]!">
        {name?.charAt(0) ?? "?"}
      </AvatarFallback>
    </Avatar>
  )
}
