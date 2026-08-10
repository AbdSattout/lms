import { PDFDocument } from "pdf-lib"

/** Wraps the rendered PNG into a single-page PDF sized to the image. */
export async function pngToPdf(
  png: ArrayBuffer | Uint8Array,
  width: number,
  height: number
): Promise<ArrayBuffer> {
  const doc = await PDFDocument.create()
  const page = doc.addPage([width, height])
  page.drawImage(await doc.embedPng(png), { x: 0, y: 0, width, height })

  const bytes = await doc.save()
  return bytes.buffer.slice(
    bytes.byteOffset,
    bytes.byteOffset + bytes.byteLength
  ) as ArrayBuffer
}
