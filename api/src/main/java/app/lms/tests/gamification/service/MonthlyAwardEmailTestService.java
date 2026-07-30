package app.lms.tests.gamification.service;

import app.lms.common.exception.BadRequestException;
import app.lms.email.service.EmailDeliveryService;
import app.lms.tests.gamification.dto.MonthlyAwardEmailTestRequest;
import app.lms.tests.gamification.dto.MonthlyAwardEmailTestResponse;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class MonthlyAwardEmailTestService {

    private static final int DEFAULT_RANK = 1;
    private static final long DEFAULT_XP = 2500L;

    private final EmailDeliveryService emailDeliveryService;

    @Value("${app.email-otp.app-name:MSAR LMS Center}")
    private String appName;

    public MonthlyAwardEmailTestResponse send(
            MonthlyAwardEmailTestRequest request
    ) {

        int rank =
                request.rank() != null
                        ? request.rank()
                        : DEFAULT_RANK;

        long xp =
                request.xp() != null
                        ? request.xp()
                        : DEFAULT_XP;

        LocalDate premiumExpiresAt =
                request.premiumExpiresAt() != null
                        ? request.premiumExpiresAt()
                        : LocalDate.now()
                                .plusMonths(1);

        String subject =
                "You won " + appName + " Premium";

        try {
            emailDeliveryService.sendHtml(
                    request.email(),
                    subject,
                    plainTextEmail(
                            rank,
                            xp,
                            premiumExpiresAt
                    ),
                    htmlEmail(
                            rank,
                            xp,
                            premiumExpiresAt
                    )
            );
        } catch (MailException |
                 MessagingException |
                 IllegalStateException ex) {
            throw new BadRequestException(
                    "Failed to send monthly award test email"
            );
        }

        return new MonthlyAwardEmailTestResponse(
                request.email(),
                subject,
                rank,
                xp,
                premiumExpiresAt,
                LocalDateTime.now()
        );
    }

    private String plainTextEmail(
            int rank,
            long xp,
            LocalDate premiumExpiresAt
    ) {

        return """
                Congratulations!

                You finished #%d on the %s monthly scoreboard with %d XP.

                Premium is now enabled on your account until %s.

                Keep learning,
                %s
                """
                .formatted(
                        rank,
                        appName,
                        xp,
                        premiumExpiresAt,
                        appName
                );
    }

    private String htmlEmail(
            int rank,
            long xp,
            LocalDate premiumExpiresAt
    ) {

        String safeAppName =
                escapeHtml(appName);

        return """
                <!doctype html>
                <html>
                <body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#172033;">
                  <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background:#f4f7fb;padding:32px 12px;">
                    <tr>
                      <td align="center">
                        <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="max-width:560px;background:#ffffff;border:1px solid #e1e7f0;border-radius:8px;overflow:hidden;">
                          <tr>
                            <td style="padding:28px 28px 12px;">
                              <div style="font-size:14px;font-weight:700;color:#2563eb;text-transform:uppercase;letter-spacing:0.04em;">%s</div>
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">Premium is enabled</h1>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">You finished in the monthly top 3 and earned a premium reward.</p>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:18px 28px 10px;">
                              <div style="background:#f8fafc;border:1px solid #dbe4ef;border-radius:8px;padding:18px;">
                                <div style="font-size:13px;color:#64748b;margin-bottom:8px;">Your result</div>
                                <div style="font-size:28px;line-height:36px;font-weight:700;color:#0f172a;">Rank #%d</div>
                                <div style="font-size:15px;line-height:24px;color:#334155;margin-top:6px;">%d XP earned</div>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:10px 28px 28px;">
                              <p style="margin:0;color:#334155;font-size:15px;line-height:24px;">Your premium access is active until <strong>%s</strong>.</p>
                              <p style="margin:14px 0 0;color:#64748b;font-size:13px;line-height:20px;">Keep learning and competing on the next monthly scoreboard.</p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """
                .formatted(
                        safeAppName,
                        rank,
                        xp,
                        premiumExpiresAt
                );
    }

    private String escapeHtml(
            String value
    ) {

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
