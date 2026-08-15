package app.lms.email.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EmailDeliveryService {

    @Value("${app.email.api-base-url:}")
    private String apiBaseUrl;

    @Value("${app.email.api-path:/}")
    private String apiPath;

    @Value("${app.email.api-secret:}")
    private String apiSecret;

    public boolean isConfigured() {
        return StringUtils.hasText(apiBaseUrl)
                && StringUtils.hasText(apiSecret);
    }

    public void sendHtml(
            String to,
            String subject,
            String plainText,
            String html
    ) {

        if (!isConfigured()) {
            throw new IllegalStateException("Transactional email API is not configured");
        }

        if (!StringUtils.hasText(plainText)
                && !StringUtils.hasText(html)) {
            throw new IllegalArgumentException("Email text or html is required");
        }

        Map<String, Object> payload =
                new LinkedHashMap<>();

        payload.put(
                "to",
                to
        );
        payload.put(
                "subject",
                subject
        );

        if (StringUtils.hasText(plainText)) {
            payload.put(
                    "text",
                    plainText
            );
        }

        if (StringUtils.hasText(html)) {
            payload.put(
                    "html",
                    html
            );
        }

        try {
            EmailApiResponse response =
                    RestClient.builder()
                            .baseUrl(
                                    apiBaseUrl.trim()
                            )
                            .build()
                            .post()
                            .uri(apiPath())
                            .header(
                                    "Authorization",
                                    "Bearer " + apiSecret.trim()
                            )
                            .contentType(MediaType.APPLICATION_JSON)
                            .body(payload)
                            .retrieve()
                            .body(EmailApiResponse.class);

            if (
                    response == null ||
                            !Boolean.TRUE.equals(response.ok())
            ) {
                throw new RuntimeException(
                        "Transactional email API rejected the message"
                );
            }
        } catch (RestClientResponseException e) {
            throw new RuntimeException(
                    "Failed to deliver email via transactional email API: HTTP "
                            + e.getStatusCode()
                            + " "
                            + e.getResponseBodyAsString(),
                    e
            );
        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to deliver email via transactional email API",
                    e
            );
        }
    }

    private String apiPath() {

        if (!StringUtils.hasText(apiPath)) {
            return "/";
        }

        String trimmed =
                apiPath.trim();

        return trimmed.startsWith("/")
                ? trimmed
                : "/" + trimmed;
    }

    private record EmailApiResponse(
            Boolean ok,
            String messageId
    ) {
    }
}
