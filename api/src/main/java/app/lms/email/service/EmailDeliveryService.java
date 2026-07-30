package app.lms.email.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class EmailDeliveryService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.host:}")
    private String mailHost;

    @Value("${app.email-otp.from:}")
    private String fromEmail;

    public boolean isConfigured() {

        return StringUtils.hasText(mailHost);
    }

    public void sendHtml(
            String to,
            String subject,
            String plainText,
            String html
    ) throws MessagingException {

        if (!isConfigured()) {
            throw new IllegalStateException(
                    "Email is not configured"
            );
        }

        MimeMessage message =
                mailSender.createMimeMessage();

        MimeMessageHelper helper =
                new MimeMessageHelper(
                        message,
                        true,
                        StandardCharsets.UTF_8.name()
                );

        if (StringUtils.hasText(fromEmail)) {
            helper.setFrom(fromEmail);
        }

        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(
                plainText,
                html
        );

        mailSender.send(message);
    }
}
