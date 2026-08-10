import QRCode from "qrcode"

const appBaseUrl = (process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000").replace(
  /\/+$/,
  ""
)

// QR scanning should land on the public verification page for the certificate,
// not just a bare code that phones would show as plain text.
export function certificateVerifyUrl(code: string): string {
  return `${appBaseUrl}/verify/${encodeURIComponent(code)}`
}

export async function generateQrDataUrl(code: string): Promise<string> {
  const buffer = await QRCode.toBuffer(certificateVerifyUrl(code), {
    type: "png",
    margin: 1,
    errorCorrectionLevel: "M",
    color: { dark: "#18181b", light: "#ffffff" },
  })
  return `data:image/png;base64,${buffer.toString("base64")}`
}