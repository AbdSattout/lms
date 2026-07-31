package app.lms.auth.service;

import app.lms.common.exception.BadRequestException;
import app.lms.email.service.EmailDeliveryService;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.mail.MailException;
import org.springframework.security.authentication.BadCredentialsException;
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

    private static final String CODE_KEY_PREFIX =
            "auth:email-otp:code:";
    private static final String ATTEMPTS_KEY_PREFIX =
            "auth:email-otp:attempts:";
    private static final String COOLDOWN_KEY_PREFIX =
            "auth:email-otp:cooldown:";

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

    public void requestOtp(
            String email
    ) {

        String normalizedEmail =
                normalizeEmail(email);

        ensureMailConfigured();
        ensureNotInCooldown(normalizedEmail);

        String otp =
                String.format(
                        "%06d",
                        secureRandom.nextInt(1_000_000)
                );

        Duration ttl =
                Duration.ofMinutes(ttlMinutes);

        redisTemplate.opsForValue().set(
                codeKey(normalizedEmail),
                hashOtp(
                        normalizedEmail,
                        otp
                ),
                ttl
        );
        redisTemplate.delete(
                attemptsKey(normalizedEmail)
        );
        redisTemplate.opsForValue().set(
                cooldownKey(normalizedEmail),
                "1",
                Duration.ofSeconds(cooldownSeconds)
        );

        try {
            sendOtpEmail(
                    normalizedEmail,
                    otp
            );

        } catch (MailException |
                 MessagingException |
                 IllegalStateException ex) {
            clearOtp(normalizedEmail);
            throw new BadRequestException(
                    "Failed to send email OTP"
            );
        }
    }

    public String verifyOtp(
            String email,
            String otp
    ) {

        String normalizedEmail =
                normalizeEmail(email);

        String storedHash =
                redisTemplate
                        .opsForValue()
                        .get(codeKey(normalizedEmail));

        if (!StringUtils.hasText(storedHash)) {
            throw invalidOtp();
        }

        Long attemptCount =
                redisTemplate
                        .opsForValue()
                        .increment(attemptsKey(normalizedEmail));

        long attempts =
                attemptCount == null ? 1 : attemptCount;

        if (attempts == 1) {
            redisTemplate.expire(
                    attemptsKey(normalizedEmail),
                    Duration.ofMinutes(ttlMinutes)
            );
        }

        if (attempts > maxAttempts) {
            clearOtp(normalizedEmail);
            throw invalidOtp();
        }

        String submittedHash =
                hashOtp(
                        normalizedEmail,
                        otp
                );

        if (!MessageDigest.isEqual(
                storedHash.getBytes(StandardCharsets.UTF_8),
                submittedHash.getBytes(StandardCharsets.UTF_8)
        )) {
            throw invalidOtp();
        }

        clearOtp(normalizedEmail);

        return normalizedEmail;
    }

    private void sendOtpEmail(
            String email,
            String otp
    ) throws MessagingException {

        emailDeliveryService.sendHtml(
                email,
                "Your " + appName + " login code",
                plainTextEmail(otp),
                htmlEmail(otp)
        );
    }

    private String plainTextEmail(
            String otp
    ) {

        return """
                Your %s login code is:

                %s

                This code expires in %d minutes.

                If you did not request this code, you can ignore this email.
                """
                .formatted(
                        appName,
                        otp,
                        ttlMinutes
                );
    }

    private String htmlEmail(
            String otp
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
                        <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border:1px solid #e1e7f0;border-radius:8px;overflow:hidden;">
                          <tr>
                            <td style="padding:28px 28px 12px;">
                              <div style="font-size:14px;font-weight:700;color:#2563eb;text-transform:uppercase;letter-spacing:0.04em;">%s</div>
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">Your login code</h1>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">Use this code to finish signing in. It expires in %d minutes.</p>
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
            String email
    ) {

        Boolean cooldownExists =
                redisTemplate.hasKey(
                        cooldownKey(email)
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
            String email,
            String otp
    ) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance("SHA-256");

            byte[] hash =
                    digest.digest(
                            (jwtSecret + ":" + email + ":" + otp)
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
            String email
    ) {

        redisTemplate.delete(
                codeKey(email)
        );
        redisTemplate.delete(
                attemptsKey(email)
        );
        redisTemplate.delete(
                cooldownKey(email)
        );
    }

    private BadCredentialsException invalidOtp() {

        return new BadCredentialsException(
                "Invalid or expired email OTP"
        );
    }

    private String codeKey(
            String email
    ) {

        return CODE_KEY_PREFIX + email;
    }

    private String attemptsKey(
            String email
    ) {

        return ATTEMPTS_KEY_PREFIX + email;
    }

    private String cooldownKey(
            String email
    ) {

        return COOLDOWN_KEY_PREFIX + email;
    }
}
