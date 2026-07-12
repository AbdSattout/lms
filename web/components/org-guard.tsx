import { notFound } from "next/navigation"

export async function OrgGuard<T>({
  promise,
}: {
  promise: Promise<T>
}) {
  await promise.catch(() => notFound())
  return null
}
