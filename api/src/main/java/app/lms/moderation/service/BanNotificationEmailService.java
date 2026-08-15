package app.lms.moderation.service;

import app.lms.email.service.EmailDeliveryService;
import app.lms.organization.model.Organization;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Service
@RequiredArgsConstructor
@Slf4j
public class BanNotificationEmailService {

    private static final DateTimeFormatter BAN_DATE_FORMATTER =
            DateTimeFormatter.ofPattern(
                    "MMM d, yyyy h:mm a",
                    Locale.ENGLISH
            );

    private final EmailDeliveryService emailDeliveryService;

    @Value("${app.email-otp.app-name:MSAR LMS Center}")
    private String appName;

    public void sendUserBan(
            User user,
            String reason,
            LocalDateTime expiresAt
    ) {

        sendBanEmail(
                user,
                "Your account has been banned",
                "Your account has been banned on " + appName + ".",
                reason,
                expiresAt,
                null
        );
    }

    public void sendOrganizationUserBan(
            User user,
            Organization organization,
            String reason,
            LocalDateTime expiresAt
    ) {

        String organizationName =
                organizationName(organization);

        sendBanEmail(
                user,
                "You have been banned from " +
                        subjectText(organizationName),
                "You have been banned from " +
                        organizationName + ".",
                reason,
                expiresAt,
                organizationName
        );
    }

    public void sendOrganizationBan(
            Organization organization,
            String reason,
            LocalDateTime expiresAt
    ) {

        User owner =
                organization.getOwner();

        String organizationName =
                organizationName(organization);

        sendBanEmail(
                owner,
                organizationName + " has been banned",
                organizationName + " has been banned on " + appName + ".",
                reason,
                expiresAt,
                organizationName
        );
    }

    private void sendBanEmail(
            User recipient,
            String subject,
            String message,
            String reason,
            LocalDateTime expiresAt,
            String organizationName
    ) {

        if (recipient == null) {
            return;
        }

        if (!StringUtils.hasText(recipient.getEmail())) {
            log.info(
                    "Skipping ban notification email because user has no email. userId={}",
                    recipient.getId()
            );
            return;
        }

        if (!emailDeliveryService.isConfigured()) {
            log.warn(
                    "Skipping ban notification email because email is not configured. userId={}",
                    recipient.getId()
            );
            return;
        }

        try {
            emailDeliveryService.sendHtml(
                    recipient.getEmail().trim(),
                    subjectText(subject),
                    plainTextEmail(
                            recipient,
                            message,
                            reason,
                            expiresAt,
                            organizationName
                    ),
                    htmlEmail(
                            recipient,
                            message,
                            reason,
                            expiresAt,
                            organizationName
                    )
            );

        } catch (RuntimeException ex) {
            log.warn(
                    "Failed to send ban notification email. userId={}",
                    recipient.getId(),
                    ex
            );
        }
    }

    private String plainTextEmail(
            User user,
            String message,
            String reason,
            LocalDateTime expiresAt,
            String organizationName
    ) {

        return """
                %s

                %s

                Status: %s
                %sReason: %s

                If you believe this was a mistake, please contact support.
                """
                .formatted(
                        greeting(user),
                        message,
                        banPeriod(expiresAt),
                        organizationNameLine(organizationName),
                        reasonText(reason)
                );
    }

    private String htmlEmail(
            User user,
            String message,
            String reason,
            LocalDateTime expiresAt,
            String organizationName
    ) {

        String safeAppName =
                escapeHtml(appName);
        String safeMessage =
                escapeHtml(message);
        String safeGreeting =
                escapeHtml(
                        greeting(user)
                );
        String safeStatus =
                escapeHtml(
                        banPeriod(expiresAt)
                );
        String safeReason =
                escapeHtml(
                        reasonText(reason)
                );
        String safeOrganizationName =
                escapeHtml(organizationName);
        String organizationBlock =
                StringUtils.hasText(organizationName)
                        ? """
                          <tr>
                            <td style="padding:0 28px 12px;">
                              <div style="font-size:13px;color:#64748b;margin-bottom:6px;">Organization</div>
                              <div style="font-size:15px;color:#111827;font-weight:700;">%s</div>
                            </td>
                          </tr>
                          """
                        .formatted(safeOrganizationName)
                        : "";

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
                              <div style="font-size:14px;font-weight:700;color:#dc2626;text-transform:uppercase;letter-spacing:0.04em;">%s</div>
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">Account access notice</h1>
                              <p style="margin:0 0 8px;color:#111827;font-size:15px;line-height:24px;font-weight:700;">%s</p>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">%s</p>
                            </td>
                          </tr>
                          %s
                          <tr>
                            <td style="padding:18px 28px 14px;">
                              <div style="background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:16px;">
                                <div style="font-size:13px;color:#991b1b;margin-bottom:8px;">Ban duration</div>
                                <div style="font-size:16px;line-height:24px;color:#7f1d1d;font-weight:700;">%s</div>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:0 28px 28px;">
                              <div style="background:#f8fafc;border:1px solid #dbe4ef;border-radius:8px;padding:16px;">
                                <div style="font-size:13px;color:#64748b;margin-bottom:8px;">Reason</div>
                                <div style="font-size:14px;line-height:22px;color:#334155;">%s</div>
                              </div>
                              <p style="margin:14px 0 0;color:#64748b;font-size:13px;line-height:20px;">If you believe this was a mistake, please contact support.</p>
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
                        safeGreeting,
                        safeMessage,
                        organizationBlock,
                        safeStatus,
                        safeReason
                );
    }

    private String banPeriod(
            LocalDateTime expiresAt
    ) {

        if (expiresAt == null) {
            return "Permanent";
        }

        return "Until " +
                expiresAt.format(
                        BAN_DATE_FORMATTER
                );
    }

    private String organizationNameLine(
            String organizationName
    ) {

        if (!StringUtils.hasText(organizationName)) {
            return "";
        }

        return "Organization: " + organizationName + "\n";
    }

    private String organizationName(
            Organization organization
    ) {

        if (
                organization != null &&
                        StringUtils.hasText(
                                organization.getName()
                        )
        ) {
            return organization.getName()
                    .trim();
        }

        return "this organization";
    }

    private String greeting(
            User user
    ) {

        if (
                user != null &&
                        StringUtils.hasText(
                                user.getName()
                        )
        ) {
            return "Hello " + user.getName()
                    .trim() + ",";
        }

        return "Hello,";
    }

    private String reasonText(
            String reason
    ) {

        if (!StringUtils.hasText(reason)) {
            return "No reason provided";
        }

        return reason.trim();
    }

    private String subjectText(
            String value
    ) {

        return value
                .replace("\r", " ")
                .replace("\n", " ")
                .trim();
    }

    private String escapeHtml(
            String value
    ) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
