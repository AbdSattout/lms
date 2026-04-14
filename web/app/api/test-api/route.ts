const DEFAULT_API_URL = "http://localhost:8080"

export async function GET() {
  const target =
    process.env.API_URL ?? process.env.NEXT_PUBLIC_API_URL ?? DEFAULT_API_URL

  try {
    const response = await fetch(target, { cache: "no-store" })
    const body = await response.text()

    return Response.json({
      ok: response.ok,
      target,
      status: response.status,
      result: body || "(empty response body)",
    })
  } catch (error) {
    return Response.json({
      ok: false,
      target,
      status: null,
      result: error instanceof Error ? error.message : "Unknown error",
    })
  }
}
