package app.lms.billing.client;

import app.lms.billing.config.PolarProperties;
import app.lms.billing.dto.CheckoutSessionResponse;
import app.lms.common.exception.BadRequestException;
import app.lms.user.model.User;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class PolarClient {

    private final PolarProperties polarProperties;
    private final ObjectMapper objectMapper =
            new ObjectMapper();

    public CheckoutSessionResponse createPremiumCheckout(
            User user
    ) {

        validateCheckoutConfiguration();

        Map<String, Object> requestBody =
                new LinkedHashMap<>();

        requestBody.put(
                "products",
                List.of(polarProperties.getPremiumProductId())
        );
        requestBody.put(
                "external_customer_id",
                user.getId().toString()
        );
        requestBody.put(
                "customer_name",
                user.getName()
        );
        requestBody.put(
                "customer_metadata",
                Map.of(
                        "user_id",
                        user.getId().toString(),
                        "telegram_id",
                        user.getTelegramId()
                )
        );
        requestBody.put(
                "metadata",
                Map.of(
                        "user_id",
                        user.getId().toString()
                )
        );
        putIfPresent(
                requestBody,
                "success_url",
                polarProperties.getCheckoutSuccessUrl()
        );
        putIfPresent(
                requestBody,
                "return_url",
                polarProperties.getCheckoutReturnUrl()
        );

        try {
            String responseBody =
                    restClient()
                            .post()
                            .uri("/checkouts/")
                            .contentType(MediaType.APPLICATION_JSON)
                            .accept(MediaType.APPLICATION_JSON)
                            .body(
                                    objectMapper.writeValueAsString(
                                            requestBody
                                    )
                            )
                            .retrieve()
                            .body(String.class);

            JsonNode response =
                    objectMapper.readTree(responseBody);

            if (response == null ||
                    !StringUtils.hasText(
                            response.path("url").asText(null)
                    )) {
                throw new BadRequestException(
                        "Polar checkout response is missing checkout URL"
                );
            }

            return new CheckoutSessionResponse(
                    response.path("id").asText(null),
                    response.path("url").asText()
            );

        } catch (RestClientException |
                 JsonProcessingException ex) {
            throw new BadRequestException(
                    "Failed to create Polar checkout session"
            );
        }
    }

    private RestClient restClient() {

        return RestClient
                .builder()
                .baseUrl(
                        normalizedBaseUrl()
                )
                .defaultHeader(
                        "Authorization",
                        "Bearer " + polarProperties.getAccessToken()
                )
                .build();
    }

    private String normalizedBaseUrl() {

        String baseUrl =
                polarProperties.getApiBaseUrl();

        if (!StringUtils.hasText(baseUrl)) {
            return "https://sandbox-api.polar.sh/v1";
        }

        if (baseUrl.endsWith("/")) {
            return baseUrl.substring(
                    0,
                    baseUrl.length() - 1
            );
        }

        return baseUrl;
    }

    private void validateCheckoutConfiguration() {

        if (!StringUtils.hasText(
                polarProperties.getAccessToken()
        )) {
            throw new BadRequestException(
                    "Polar access token is not configured"
            );
        }

        if (!StringUtils.hasText(
                polarProperties.getPremiumProductId()
        )) {
            throw new BadRequestException(
                    "Polar premium product ID is not configured"
            );
        }
    }

    private void putIfPresent(
            Map<String, Object> requestBody,
            String key,
            String value
    ) {

        if (!StringUtils.hasText(value)) {
            return;
        }

        requestBody.put(
                key,
                value
        );
    }
}
