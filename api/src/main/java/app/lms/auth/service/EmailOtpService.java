package app.lms.auth.service;

import app.lms.common.exception.BadRequestException;
import app.lms.email.service.EmailDeliveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.HexFormat;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class EmailOtpService {

    private static final String KEY_PREFIX =
            "auth:email-otp:";

    private final StringRedisTemplate redisTemplate;
    private final EmailDeliveryService emailDeliveryService;
    private final SecureRandom secureRandom =
            new SecureRandom();

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${app.email-otp.ttl-minutes}")
    private long ttlMinutes;

    @Value("${app.email-otp.cooldown-seconds}")
    private long cooldownSeconds;

    @Value("${app.email-otp.max-attempts}")
    private long maxAttempts;

    @Value("${app.email-otp.app-name}")
    private String appName;

    public void requestLoginOtp(
            String email
    ) {

        requestOtp(
                email,
                EmailOtpPurpose.EMAIL_LOGIN
        );
    }

    public String verifyLoginOtp(
            String email,
            String otp
    ) {

        return verifyOtp(
                email,
                otp,
                EmailOtpPurpose.EMAIL_LOGIN
        );
    }

    public void requestSetUserEmailOtp(
            String email
    ) {

        requestOtp(
                email,
                EmailOtpPurpose.SET_USER_EMAIL
        );
    }

    public String verifySetUserEmailOtp(
            String email,
            String otp
    ) {

        return verifyOtp(
                email,
                otp,
                EmailOtpPurpose.SET_USER_EMAIL
        );
    }

    private void requestOtp(
            String email,
            EmailOtpPurpose purpose
    ) {

        String normalizedEmail =
                normalizeEmail(email);

        ensureMailConfigured();
        ensureNotInCooldown(
                purpose,
                normalizedEmail
        );

        String otp =
                String.format(
                        "%06d",
                        secureRandom.nextInt(1_000_000)
                );

        Duration ttl =
                Duration.ofMinutes(ttlMinutes);

        redisTemplate.opsForValue().set(
                codeKey(
                        purpose,
                        normalizedEmail
                ),
                hashOtp(
                        purpose,
                        normalizedEmail,
                        otp
                ),
                ttl
        );
        redisTemplate.delete(
                attemptsKey(
                        purpose,
                        normalizedEmail
                )
        );
        redisTemplate.opsForValue().set(
                cooldownKey(
                        purpose,
                        normalizedEmail
                ),
                "1",
                Duration.ofSeconds(cooldownSeconds)
        );

        try {
            sendOtpEmail(
                    normalizedEmail,
                    otp,
                    purpose
            );

        } catch (RuntimeException ex) {
            clearOtp(
                    purpose,
                    normalizedEmail
            );
            throw new BadRequestException(
                    "Failed to send email OTP"
            );
        }
    }

    private String verifyOtp(
            String email,
            String otp,
            EmailOtpPurpose purpose
    ) {

        String normalizedEmail =
                normalizeEmail(email);

        String storedHash =
                redisTemplate
                        .opsForValue()
                        .get(
                                codeKey(
                                        purpose,
                                        normalizedEmail
                                )
                        );

        if (!StringUtils.hasText(storedHash)) {
            throw invalidOtp();
        }

        Long attemptCount =
                redisTemplate
                        .opsForValue()
                        .increment(
                                attemptsKey(
                                        purpose,
                                        normalizedEmail
                                )
                        );

        long attempts =
                attemptCount == null ? 1 : attemptCount;

        if (attempts == 1) {
            redisTemplate.expire(
                    attemptsKey(
                            purpose,
                            normalizedEmail
                    ),
                    Duration.ofMinutes(ttlMinutes)
            );
        }

        if (attempts > maxAttempts) {
            clearOtp(
                    purpose,
                    normalizedEmail
            );
            throw invalidOtp();
        }

        String submittedHash =
                hashOtp(
                        purpose,
                        normalizedEmail,
                        otp
                );

        if (!MessageDigest.isEqual(
                storedHash.getBytes(StandardCharsets.UTF_8),
                submittedHash.getBytes(StandardCharsets.UTF_8)
        )) {
            throw invalidOtp();
        }

        clearOtp(
                purpose,
                normalizedEmail
        );

        return normalizedEmail;
    }

    private void sendOtpEmail(
            String email,
            String otp,
            EmailOtpPurpose purpose
    ) {

        emailDeliveryService.sendHtml(
                email,
                "Your " + appName + " " + purpose.subject(),
                plainTextEmail(
                        otp,
                        purpose
                ),
                htmlEmail(
                        otp,
                        purpose
                )
        );
    }

    private String plainTextEmail(
            String otp,
            EmailOtpPurpose purpose
    ) {

        return """
                Your %s %s is:

                %s

                This code expires in %d minutes.

                If you did not request this code, you can ignore this email.
                """
                .formatted(
                        appName,
                        purpose.subject(),
                        otp,
                        ttlMinutes
                );
    }

    private String htmlEmail(
            String otp,
            EmailOtpPurpose purpose
    ) {

        String safeAppName =
                escapeHtml(appName);
        String safeHeading =
                escapeHtml(
                        purpose.heading()
                );
        String safeMessage =
                escapeHtml(
                        purpose.message()
                );

        return """
                <!doctype html>
                <html>
                <body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#172033;">
                  <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background:#f4f7fb;padding:32px 12px;">
                    <tr>
                      <td align="center">
                        <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border:1px solid #e1e7f0;border-radius:8px;overflow:hidden;">
                          <tr>
                            <td style="padding:28px 28px 12px;">
                              <div style="font-size:14px;font-weight:700;color:#2563eb;text-transform:uppercase;letter-spacing:0.04em;">%s</div>
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">%s</h1>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">%s It expires in %d minutes.</p>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:18px 28px 10px;">
                              <div style="background:#f8fafc;border:1px solid #dbe4ef;border-radius:8px;padding:18px;text-align:center;">
                                <div style="font-size:13px;color:#64748b;margin-bottom:8px;">Copy this code</div>
                                <div style="font-size:34px;line-height:42px;font-weight:700;letter-spacing:8px;color:#0f172a;font-family:'Courier New',Courier,monospace;">%s</div>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:10px 28px 28px;">
                              <p style="margin:0;color:#64748b;font-size:13px;line-height:20px;">If you did not request this code, you can ignore this email.</p>
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
                        safeHeading,
                        safeMessage,
                        ttlMinutes,
                        otp
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

    private void ensureMailConfigured() {

        if (!emailDeliveryService.isConfigured()) {
            throw new BadRequestException(
                    "Email OTP is not configured"
            );
        }
    }

    private void ensureNotInCooldown(
            EmailOtpPurpose purpose,
            String email
    ) {

        Boolean cooldownExists =
                redisTemplate.hasKey(
                        cooldownKey(
                                purpose,
                                email
                        )
                );

        if (Boolean.TRUE.equals(cooldownExists)) {
            throw new BadRequestException(
                    "OTP was sent recently. Please wait before requesting another code"
            );
        }
    }

    private String normalizeEmail(
            String email
    ) {

        return email
                .trim()
                .toLowerCase(Locale.ROOT);
    }

    private String hashOtp(
            EmailOtpPurpose purpose,
            String email,
            String otp
    ) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance("SHA-256");

            byte[] hash =
                    digest.digest(
                            (jwtSecret + ":" +
                                    purpose.name() + ":" +
                                    email + ":" +
                                    otp)
                                    .getBytes(StandardCharsets.UTF_8)
                    );

            return HexFormat.of().formatHex(hash);

        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException(
                    "SHA-256 is not available",
                    ex
            );
        }
    }

    private void clearOtp(
            EmailOtpPurpose purpose,
            String email
    ) {

        redisTemplate.delete(
                codeKey(
                        purpose,
                        email
                )
        );
        redisTemplate.delete(
                attemptsKey(
                        purpose,
                        email
                )
        );
        redisTemplate.delete(
                cooldownKey(
                        purpose,
                        email
                )
        );
    }

    private BadRequestException invalidOtp() {

        return new BadRequestException(
                "Invalid or expired email OTP"
        );
    }

    private String codeKey(
            EmailOtpPurpose purpose,
            String email
    ) {

        return KEY_PREFIX + purpose.keySegment() + ":code:" + email;
    }

    private String attemptsKey(
            EmailOtpPurpose purpose,
            String email
    ) {

        return KEY_PREFIX + purpose.keySegment() + ":attempts:" + email;
    }

    private String cooldownKey(
            EmailOtpPurpose purpose,
            String email
    ) {

        return KEY_PREFIX + purpose.keySegment() + ":cooldown:" + email;
    }

    private enum EmailOtpPurpose {
        EMAIL_LOGIN(
                "email-login",
                "login code",
                "Your login code",
                "Use this code to finish signing in."
        ),
        SET_USER_EMAIL(
                "set-user-email",
                "email verification code",
                "Verify your email",
                "Use this code to verify your email address."
        );

        private final String keySegment;
        private final String subject;
        private final String heading;
        private final String message;

        EmailOtpPurpose(
                String keySegment,
                String subject,
                String heading,
                String message
        ) {

            this.keySegment =
                    keySegment;
            this.subject =
                    subject;
            this.heading =
                    heading;
            this.message =
                    message;
        }

        private String keySegment() {

            return keySegment;
        }

        private String subject() {

            return subject;
        }

        private String heading() {

            return heading;
        }

        private String message() {

            return message;
        }
    }
}
