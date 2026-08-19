package app.lms.organization.organizationInvite.service;

import app.lms.email.service.EmailDeliveryService;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrganizationInviteEmailService {

    private static final String DEFAULT_INVITE_URL_TEMPLATE =
            "/organizations/{slug}/invites/{inviteId}";

    private static final DateTimeFormatter EXPIRY_DATE_FORMATTER =
            DateTimeFormatter.ofPattern(
                    "MMM d, yyyy",
                    Locale.ENGLISH
            );

    private final EmailDeliveryService emailDeliveryService;

    @Value("${app.email-otp.app-name:MSAR LMS Center}")
    private String appName;

    @Value("${app.organization-invites.url-template:${app.web-app.base-url:https://lmscenter.vercel.app}/organizations/{slug}/invites/{inviteId}}")
    private String inviteUrlTemplate;

    @Value("${app.web-app.base-url:https://lmscenter.vercel.app}")
    private String webAppBaseUrl;

    public void sendPrivateInvite(
            OrganizationInvite invite
    ) {

        User targetUser =
                invite.getUser();

        if (targetUser == null) {
            return;
        }

        if (!StringUtils.hasText(targetUser.getEmail())) {
            log.info(
                    "Skipping organization invite email because user has no email. inviteId={}, userId={}",
                    invite.getId(),
                    targetUser.getId()
            );
            return;
        }

        if (!emailDeliveryService.isConfigured()) {
            log.warn(
                    "Skipping organization invite email because email is not configured. inviteId={}, userId={}",
                    invite.getId(),
                    targetUser.getId()
            );
            return;
        }

        String inviteUrl =
                inviteUrl(invite);

        try {
            emailDeliveryService.sendHtml(
                    targetUser.getEmail().trim(),
                    subject(invite),
                    plainTextEmail(
                            invite,
                            inviteUrl
                    ),
                    htmlEmail(
                            invite,
                            inviteUrl
                    )
            );

        } catch (RuntimeException ex) {
            log.warn(
                    "Failed to send organization invite email. inviteId={}, userId={}",
                    invite.getId(),
                    targetUser.getId(),
                    ex
            );
        }
    }

    private String subject(
            OrganizationInvite invite
    ) {

        return "You are invited to " +
                subjectText(
                        organizationName(invite)
                );
    }

    private String plainTextEmail(
            OrganizationInvite invite,
            String inviteUrl
    ) {

        return """
                %s

                %s invited you to join %s on %s.

                Open your invitation:
                %s

                Role: %s
                Expires: %s

                If you were not expecting this invitation, you can ignore this email.
                """
                .formatted(
                        greeting(invite.getUser()),
                        inviterName(invite),
                        organizationName(invite),
                        appName,
                        inviteUrl,
                        roleLabel(invite.getRole()),
                        expiresAt(invite)
                );
    }

    private String htmlEmail(
            OrganizationInvite invite,
            String inviteUrl
    ) {

        String safeAppName =
                escapeHtml(appName);
        String safeOrganizationName =
                escapeHtml(
                        organizationName(invite)
                );
        String safeInviterName =
                escapeHtml(
                        inviterName(invite)
                );
        String safeRole =
                escapeHtml(
                        roleLabel(invite.getRole())
                );
        String safeExpiresAt =
                escapeHtml(
                        expiresAt(invite)
                );
        String safeInviteUrl =
                escapeHtml(inviteUrl);

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
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">You are invited to %s</h1>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">%s invited you to join this organization with the <strong>%s</strong> role.</p>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:20px 28px 14px;">
                              <a href="%s" style="display:inline-block;background:#2563eb;color:#ffffff;text-decoration:none;border-radius:8px;padding:13px 20px;font-size:15px;font-weight:700;">Open invitation</a>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:0 28px 18px;">
                              <div style="background:#f8fafc;border:1px solid #dbe4ef;border-radius:8px;padding:16px;">
                                <div style="font-size:13px;color:#64748b;margin-bottom:8px;">Invitation link</div>
                                <div style="font-size:13px;line-height:20px;color:#334155;word-break:break-all;">%s</div>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:0 28px 28px;">
                              <p style="margin:0;color:#334155;font-size:15px;line-height:24px;">This invitation expires on <strong>%s</strong>.</p>
                              <p style="margin:12px 0 0;color:#64748b;font-size:13px;line-height:20px;">If you were not expecting this invitation, you can ignore this email.</p>
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
                        safeOrganizationName,
                        safeInviterName,
                        safeRole,
                        safeInviteUrl,
                        safeInviteUrl,
                        safeExpiresAt
                );
    }

    private String inviteUrl(
            OrganizationInvite invite
    ) {

        String inviteId =
                String.valueOf(
                        invite.getId()
                );

        String template =
                StringUtils.hasText(inviteUrlTemplate)
                        ? inviteUrlTemplate
                        : DEFAULT_INVITE_URL_TEMPLATE;

        if (template.startsWith("/")) {
            template = stripTrailingSlash(webAppBaseUrl) + template;
        }

        return template
                .replace(
                        "{slug}",
                        organizationSlug(invite)
                )
                .replace(
                        "%7Bslug%7D",
                        organizationSlug(invite)
                )
                .replace(
                        "{inviteId}",
                        inviteId
                )
                .replace(
                        "%7BinviteId%7D",
                        inviteId
                );
    }

    private String organizationName(
            OrganizationInvite invite
    ) {

        Organization organization =
                invite.getOrganization();

        if (organization != null &&
                StringUtils.hasText(organization.getName())) {
            return organization.getName()
                    .trim();
        }

        return "this organization";
    }

    private String organizationSlug(
            OrganizationInvite invite
    ) {

        Organization organization =
                invite.getOrganization();

        if (organization != null &&
                StringUtils.hasText(organization.getSlug())) {
            return organization.getSlug()
                    .trim();
        }

        return "";
    }

    private String inviterName(
            OrganizationInvite invite
    ) {

        User invitedBy =
                invite.getInvitedBy();

        if (invitedBy != null &&
                StringUtils.hasText(invitedBy.getName())) {
            return invitedBy.getName()
                    .trim();
        }

        return appName;
    }

    private String greeting(
            User user
    ) {

        if (user != null &&
                StringUtils.hasText(user.getName())) {
            return "Hello " + user.getName()
                    .trim() + ",";
        }

        return "Hello,";
    }

    private String roleLabel(
            Role role
    ) {

        if (role == null) {
            return "Student";
        }

        return switch (role) {
            case ADMIN -> "Admin";
            case OWNER -> "Owner";
            case STUDENT -> "Student";
        };
    }

    private String expiresAt(
            OrganizationInvite invite
    ) {

        if (invite.getExpiresAt() == null) {
            return "the expiration date";
        }

        return invite.getExpiresAt()
                .format(EXPIRY_DATE_FORMATTER);
    }

    private String subjectText(
            String value
    ) {

        return value
                .replace("\r", " ")
                .replace("\n", " ")
                .trim();
    }

    private String stripTrailingSlash(
            String url
    ) {

        if (url == null) {
            return "";
        }

        return url.replaceAll("/+$", "");
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
