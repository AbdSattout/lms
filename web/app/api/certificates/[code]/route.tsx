import { unstable_cache } from "next/cache"
import { ImageResponse } from "next/og"
import { NextRequest } from "next/server"

import {
  CERTIFICATE_TAG,
  getCertificate,
  isCertificateNotFound,
  SAFE_CODE_PATTERN,
} from "@/lib/certificate/data"
import { getCertificateFonts } from "@/lib/certificate/fonts"
import { pngToPdf } from "@/lib/certificate/pdf"
import { generateQrDataUrl } from "@/lib/certificate/qrcode"
import { CertificateTemplate } from "@/lib/certificate/template"

const WIDTH = 1600
const HEIGHT = 1132 // A4 landscape ratio

type CertType = "png" | "pdf"

const renderCertificate = unstable_cache(
  async (code: string, type: CertType): Promise<string> => {
    const [cert, fonts, qrDataUrl] = await Promise.all([
      getCertificate(code),
      getCertificateFonts(),
      generateQrDataUrl(code),
    ])

    const image = new ImageResponse(
      <CertificateTemplate cert={cert} qrDataUrl={qrDataUrl} />,
      { width: WIDTH, height: HEIGHT, fonts }
    )
    const png = Buffer.from(await image.arrayBuffer())

    if (type === "png") return png.toString("base64")

    const pdf = Buffer.from(await pngToPdf(png, WIDTH, HEIGHT))
    return pdf.toString("base64")
  },
  ["certificate-render"],
  { tags: [CERTIFICATE_TAG] }
)

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ code: string }> }
) {
  const { code } = await params
  const typeParam = (
    req.nextUrl.searchParams.get("type") ?? "png"
  ).toLowerCase()

  const type: CertType | null =
    typeParam === "png" || typeParam === "pdf" ? typeParam : null
  if (!type) {
    return new Response("type must be png or pdf", { status: 400 })
  }
  if (!SAFE_CODE_PATTERN.test(code)) {
    return new Response("Invalid certificate code", { status: 400 })
  }

  try {
    const base64 = await renderCertificate(code, type)
    const bytes = Buffer.from(base64, "base64")
    const body = bytes.buffer.slice(
      bytes.byteOffset,
      bytes.byteOffset + bytes.byteLength
    ) as ArrayBuffer
    return respond(body, type, code)
  } catch (err) {
    if (isCertificateNotFound(err)) {
      return new Response("Certificate not found", { status: 404 })
    }
    console.error("Certificate render error:", err)
    return new Response("Failed to generate certificate", { status: 500 })
  }
}

function respond(data: ArrayBuffer, type: CertType, code: string) {
  const isPdf = type === "pdf"
  return new Response(data, {
    headers: {
      "Content-Type": isPdf ? "application/pdf" : "image/png",
      "Content-Disposition": `${isPdf ? "attachment" : "inline"}; filename="${code}.${type}"`,
      "Cache-Control": "public, max-age=31536000, immutable",
    },
  })
}
