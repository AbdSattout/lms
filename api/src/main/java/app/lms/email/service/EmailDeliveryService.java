package app.lms.email.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class EmailDeliveryService {

    @Value("${app.email.api-key:}")
    private String apiKey;

    @Value("${app.email-otp.from:}")
    private String fromEmail;

    private final RestClient restClient = RestClient.builder()
            .baseUrl("https://api.resend.com")
            .build();

    public boolean isConfigured() {
        return StringUtils.hasText(apiKey) && StringUtils.hasText(fromEmail);
    }

    public void sendHtml(
            String to,
            String subject,
            String plainText,
            String html
    ) {

        if (!isConfigured()) {
            throw new IllegalStateException("Resend Email HTTPS API is not configured");
        }

        Map<String, Object> payload = Map.of(
                "from", fromEmail,
                "to", new String[]{to},
                "subject", subject,
                "text", plainText,
                "html", html
        );

        try {
            restClient.post()
                    .uri("/emails")
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(payload)
                    .retrieve()
                    .toBodilessEntity();
        } catch (Exception e) {
            throw new RuntimeException("Failed to deliver email via Resend HTTPS API on Railway", e);
        }
    }
}
