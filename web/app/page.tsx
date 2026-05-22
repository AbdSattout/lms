import { LogoutButton } from "@/components/auth/logout-button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { api } from "@/lib/api"
import { UserRound } from "lucide-react"

export default async function HomePage() {
  const me = await api.users.me()

  return (
    <main className="flex min-h-dvh items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <Avatar size="lg">
          <AvatarImage src={me.picture ?? undefined} alt={me.name} />
          <AvatarFallback>
            <UserRound className="size-4" />
          </AvatarFallback>
        </Avatar>
        <h1 className="mb-3 font-heading text-4xl">{me.name}</h1>
        <LogoutButton />
      </div>
    </main>
  )
}
