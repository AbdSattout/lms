import type { CertificateResponse } from "@/lib/api/types"
import { gradeLabels, theme } from "./theme"

export function CertificateTemplate({
  cert,
  qrDataUrl,
}: {
  cert: CertificateResponse
  qrDataUrl: string
}) {
  return (
    <div
      tw="flex"
      style={{
        width: "100%",
        height: "100%",
        padding: 26,
        fontFamily: "IBM Plex Sans Arabic",
        backgroundColor: theme.primary,
      }}
    >
      <div
        tw="flex flex-col"
        style={{
          flex: 1,
          backgroundColor: theme.background,
          border: `2px solid ${theme.primary}`,
          borderRadius: 18,
          padding: "34px 56px 34px",
        }}
      >
        {/* header */}
        <div tw="flex flex-col items-center">
          <div
            style={{
              fontSize: 52,
              lineHeight: 1.3,
              fontFamily: "Lalezar",
              color: theme.primary,
              textAlign: "center",
            }}
          >
            مسار
          </div>
          <div
            style={{
              fontSize: 34,
              fontWeight: 600,
              lineHeight: 1.4,
              color: theme.foreground,
              textAlign: "center",
            }}
          >
            شهادة إتمام
          </div>
        </div>

        <div
          tw="flex items-center"
          style={{ gap: 12, marginTop: 18, marginBottom: 8 }}
        >
          <div style={{ flex: 1, height: 2, backgroundColor: theme.border }} />
          <div
            style={{
              width: 8,
              height: 8,
              borderRadius: 4,
              backgroundColor: theme.primary,
            }}
          />
          <div style={{ flex: 1, height: 2, backgroundColor: theme.border }} />
        </div>

        <div
          tw="flex flex-col items-center justify-center flex-1"
          style={{ gap: 10, padding: "20px 0" }}
        >
          <div
            style={{ fontSize: 26, color: theme.muted, textAlign: "center" }}
          >
            تمنح هذه الشهادة إلى
          </div>
          <div
            style={{
              fontSize: 84,
              lineHeight: 1.35,
              fontFamily: "Lalezar",
              color: theme.foreground,
              textAlign: "center",
            }}
          >
            {cert.studentName}
          </div>

          <div
            tw="flex flex-col items-center"
            style={{
              fontSize: 26,
              lineHeight: 1.6,
              color: theme.muted,
            }}
          >
            <div style={{ textAlign: "center" }}>لإتمامه بنجاح دورة</div>
            <div
              style={{
                textAlign: "center",
                color: theme.primary,
                fontWeight: 800,
                fontSize: 30,
              }}
            >
              {cert.courseName}
            </div>
            <div style={{ textAlign: "center" }}>
              {`بتقدير ${gradeLabels[cert.grade]}`}
            </div>
          </div>
        </div>

        <div tw="flex items-center justify-between" style={{ gap: 24 }}>
          <div tw="flex flex-col items-center" style={{ gap: 8 }}>
            <span
              style={{ fontSize: 20, color: theme.muted, textAlign: "center" }}
            >
              الجهة المانحة
            </span>
            <span
              style={{
                fontSize: 28,
                fontWeight: 600,
                lineHeight: 1.4,
                fontFamily: "Lalezar",
                color: theme.foreground,
                textAlign: "center",
              }}
            >
              {cert.organization.name}
            </span>
          </div>

          <div tw="flex flex-col items-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={qrDataUrl}
              alt=""
              width={96}
              height={96}
              style={{ borderRadius: 8, border: `1px solid ${theme.border}` }}
            />
          </div>
        </div>
      </div>
    </div>
  )
}
