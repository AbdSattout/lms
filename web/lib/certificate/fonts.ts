export type FontWeight = 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900

export interface LoadedFont {
  name: string
  data: ArrayBuffer
  weight: FontWeight
  style: "normal" | "italic"
}

const FAMILIES = ["Lalezar", "IBM Plex Sans Arabic:wght@400;500;600"]

// Google's css2 API serves woff2 by default, which Satori can't parse.
// Requesting with an old Android UA makes it return TTFs, one @font-face
// per weight. `force-cache` lets the bytes ride Next's Data Cache.
const TTF_REQUEST_HEADERS = {
  "user-agent":
    "Mozilla/5.0 (Linux; U; Android 2.3.5; en-us; Nexus One Build/GRJ90) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
}

export async function getCertificateFonts(): Promise<LoadedFont[]> {
  const families = await Promise.all(
    FAMILIES.map(async (spec) => {
      const [name] = spec.split(":")
      const css = await fetchFontCss(spec)
      return parseFaces(css).map(({ weight, url }) => ({ name, weight, url }))
    })
  )

  return Promise.all(
    families.flat().map(async ({ name, weight, url }) => {
      const res = await fetch(url, { cache: "force-cache" })
      if (!res.ok) throw new Error(`Failed to load font: ${res.status} ${url}`)
      return { name, weight, data: await res.arrayBuffer(), style: "normal" }
    })
  )
}

async function fetchFontCss(spec: string): Promise<string> {
  const url = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(
    spec
  )}&display=swap`
  const res = await fetch(url, {
    cache: "force-cache",
    headers: TTF_REQUEST_HEADERS,
  })
  if (!res.ok) throw new Error(`Failed to load font css: ${res.status}`)
  return res.text()
}

function parseFaces(css: string) {
  const faces: Array<{ weight: FontWeight; url: string }> = []

  for (const block of css.split("@font-face").slice(1)) {
    const weight = block.match(/font-weight:\s*(\d+)/)?.[1] as
      FontWeight | undefined
    const url = block.match(/url\(([^)]+)\)/)?.[1]
    if (!weight || !url) continue
    faces.push({ weight, url })
  }

  return faces
}
