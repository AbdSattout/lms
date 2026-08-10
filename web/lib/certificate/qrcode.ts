import QRCode from "qrcode"

export async function generateQrDataUrl(code: string): Promise<string> {
  const buffer = await QRCode.toBuffer(code, {
    type: "png",
    margin: 1,
    errorCorrectionLevel: "M",
    color: { dark: "#18181b", light: "#ffffff" },
  })
  return `data:image/png;base64,${buffer.toString("base64")}`
}
