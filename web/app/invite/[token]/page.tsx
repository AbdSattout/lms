import { InviteRedirectClient } from "./invite-client"

type InvitePageProps = {
  params: Promise<{ token: string }>
}

export default async function InvitePage({ params }: InvitePageProps) {
  const { token } = await params

  return <InviteRedirectClient token={token} />
}
