"use client"

import { useActionState, useEffect, useState } from "react"
import { BadgeCheck, Clock3, FileCheck2, Loader2, XCircle } from "lucide-react"

import { OrganizationVerifiedBadge } from "@/components/organization-verified-badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { submitOrganizationVerificationAction } from "@/lib/actions/organization"
import type {
  OrganizationResponse,
  OrganizationVerificationResponse,
} from "@/lib/api/types"

type VerificationState = { error?: string; success?: boolean }

export function OrganizationVerificationCard({
  organization,
  requests,
}: {
  organization: OrganizationResponse
  requests: OrganizationVerificationResponse[]
}) {
  const [state, formAction, isPending] = useActionState<
    VerificationState,
    FormData
  >(submitOrganizationVerificationAction, { success: false })
  const [proofName, setProofName] = useState("")
  const [submitted, setSubmitted] = useState(false)

  useEffect(() => {
    if (state.success) {
      setSubmitted(true)
      setProofName("")
    }
  }, [state.success])

  const latestRequest = requests[0]
  const hasPendingRequest =
    submitted || requests.some((request) => request.status === "PENDING")
  const canSubmit = !organization.verified && !hasPendingRequest

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between gap-3">
          <CardTitle className="text-base">Organization verification</CardTitle>
          {organization.verified ? (
            <OrganizationVerifiedBadge showLabel />
          ) : hasPendingRequest ? (
            <span className="inline-flex items-center gap-1 rounded-full bg-amber-500/10 px-2 py-0.5 text-xs font-semibold text-amber-700 dark:text-amber-400">
              <Clock3 className="h-3.5 w-3.5" />
              Pending
            </span>
          ) : null}
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {organization.verified ? (
          <StatusMessage
            icon={<BadgeCheck className="h-5 w-5" />}
            tone="success"
            title="This organization is verified."
            description="The verified badge is now shown anywhere this organization appears."
          />
        ) : hasPendingRequest ? (
          <StatusMessage
            icon={<Clock3 className="h-5 w-5" />}
            tone="pending"
            title="Verification request is pending."
            description="An admin needs to review the submitted proof before the badge appears."
          />
        ) : canSubmit ? (
          <form action={formAction} className="space-y-4">
            <input type="hidden" name="slug" value={organization.slug} />

            <div className="space-y-2">
              <Label htmlFor="verification-note">Note</Label>
              <Textarea
                id="verification-note"
                name="note"
                placeholder="Add any context admins should review."
                className="min-h-24 resize-y"
                disabled={isPending}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="verification-proof">Proof file</Label>
              <Input
                id="verification-proof"
                name="proof"
                type="file"
                required
                disabled={isPending}
                onChange={(event) =>
                  setProofName(event.target.files?.[0]?.name ?? "")
                }
              />
              {proofName && (
                <p className="flex items-center gap-1 text-xs text-muted-foreground">
                  <FileCheck2 className="h-3.5 w-3.5" />
                  {proofName}
                </p>
              )}
            </div>

            {state.error && (
              <p className="text-sm text-destructive">{state.error}</p>
            )}

            <Button type="submit" disabled={isPending}>
              {isPending && <Loader2 className="ml-2 h-4 w-4 animate-spin" />}
              Submit verification request
            </Button>
          </form>
        ) : null}

        {latestRequest && (
          <div className="rounded-lg border bg-muted/30 p-3 text-sm">
            <div className="flex items-center justify-between gap-3">
              <span className="font-semibold">Latest request</span>
              <VerificationStatus status={latestRequest.status} />
            </div>
            {latestRequest.adminNote && (
              <p className="mt-2 text-muted-foreground">
                {latestRequest.adminNote}
              </p>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

function StatusMessage({
  icon,
  tone,
  title,
  description,
}: {
  icon: React.ReactNode
  tone: "success" | "pending"
  title: string
  description: string
}) {
  return (
    <div
      className={
        tone === "success"
          ? "rounded-lg border border-sky-200 bg-sky-50 p-4 text-sky-800 dark:border-sky-900 dark:bg-sky-950/20 dark:text-sky-300"
          : "rounded-lg border border-amber-200 bg-amber-50 p-4 text-amber-800 dark:border-amber-900 dark:bg-amber-950/20 dark:text-amber-300"
      }
    >
      <div className="flex items-start gap-3">
        {icon}
        <div>
          <p className="font-semibold">{title}</p>
          <p className="mt-1 text-sm opacity-80">{description}</p>
        </div>
      </div>
    </div>
  )
}

function VerificationStatus({
  status,
}: {
  status: OrganizationVerificationResponse["status"]
}) {
  if (status === "APPROVED") {
    return <OrganizationVerifiedBadge showLabel />
  }

  if (status === "REJECTED") {
    return (
      <span className="inline-flex items-center gap-1 rounded-full bg-destructive/10 px-2 py-0.5 text-xs font-semibold text-destructive">
        <XCircle className="h-3.5 w-3.5" />
        Rejected
      </span>
    )
  }

  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-amber-500/10 px-2 py-0.5 text-xs font-semibold text-amber-700 dark:text-amber-400">
      <Clock3 className="h-3.5 w-3.5" />
      Pending
    </span>
  )
}
