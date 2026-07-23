package app.lms.billing.service;

import app.lms.billing.config.PolarProperties;
import app.lms.common.exception.ForbiddenException;
import com.standardwebhooks.Webhook;
import com.standardwebhooks.exceptions.WebhookVerificationException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class PolarWebhookVerifier {

    private final PolarProperties polarProperties;

    public void verify(
            String payload,
            HttpHeaders headers
    ) {

        if (!StringUtils.hasText(
                polarProperties.getWebhookSecret()
        )) {
            throw new ForbiddenException(
                    "Polar webhook secret is not configured"
            );
        }

        try {
            Webhook webhook =
                    new Webhook(
                            secretForStandardWebhooks()
                    );

            webhook.verify(
                    payload,
                    headersMap(headers)
            );

        } catch (WebhookVerificationException |
                 IllegalArgumentException ex) {
            throw new ForbiddenException(
                    "Invalid Polar webhook signature"
            );
        }
    }

    private String secretForStandardWebhooks() {

        String secret =
                polarProperties.getWebhookSecret()
                        .trim();

        if (secret.startsWith("whsec_")) {
            return secret;
        }

        return Base64
                .getEncoder()
                .encodeToString(
                        secret.getBytes(
                                StandardCharsets.UTF_8
                        )
                );
    }

    private Map<String, List<String>> headersMap(
            HttpHeaders headers
    ) {

        Map<String, List<String>> result =
                new LinkedHashMap<>();

        headers.forEach(result::put);

        return result;
    }
}
