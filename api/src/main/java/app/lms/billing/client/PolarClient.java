package app.lms.billing.client;

import app.lms.billing.config.PolarProperties;
import app.lms.billing.dto.CheckoutSessionResponse;
import app.lms.billing.dto.CustomerPortalSessionResponse;
import app.lms.billing.enums.CheckoutClient;
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
import org.springframework.web.client.RestClientResponseException;

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

        return createPremiumCheckout(
                user,
                CheckoutClient.DEFAULT
        );
    }

    public CheckoutSessionResponse createPremiumCheckout(
            User user,
            CheckoutClient client
    ) {

        validateCheckoutConfiguration();
        CheckoutClient safeClient =
                CheckoutClient.orDefault(
                        client
                );

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
        Map<String, Object> customerMetadata =
                new LinkedHashMap<>();
        customerMetadata.put(
                "user_id",
                user.getId().toString()
        );
        putIfPresent(
                customerMetadata,
                "telegram_id",
                user.getTelegramId()
        );
        putIfPresent(
                customerMetadata,
                "google_id",
                user.getGoogleId()
        );
        requestBody.put(
                "customer_metadata",
                customerMetadata
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
                checkoutSuccessUrl(safeClient)
        );
        putIfPresent(
                requestBody,
                "return_url",
                checkoutReturnUrl(safeClient)
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

        } catch (RestClientResponseException ex) {
            throw new BadRequestException(
                    "Failed to create Polar checkout session: " +
                            polarErrorMessage(ex)
            );
        } catch (RestClientException |
                 JsonProcessingException ex) {
            throw new BadRequestException(
                    "Failed to create Polar checkout session: " +
                            ex.getMessage()
            );
        }
    }

    public CustomerPortalSessionResponse createCustomerPortalSession(
            String polarCustomerId
    ) {

        validateAccessToken();

        if (!StringUtils.hasText(polarCustomerId)) {
            throw new BadRequestException(
                    "Polar customer ID is missing"
            );
        }

        Map<String, Object> requestBody =
                new LinkedHashMap<>();

        requestBody.put(
                "customer_id",
                polarCustomerId
        );
        putIfPresent(
                requestBody,
                "return_url",
                polarProperties.getCustomerPortalReturnUrl()
        );

        try {
            String responseBody =
                    restClient()
                            .post()
                            .uri("/customer-sessions/")
                            .contentType(MediaType.APPLICATION_JSON)
                            .accept(MediaType.APPLICATION_JSON)
                            .body(
                                    objectMapper.writeValueAsString(
                                            requestBody
                                    )
                            )
                            .retrieve()
                            .body(String.class);

            if (!StringUtils.hasText(responseBody)) {
                throw new BadRequestException(
                        "Polar customer session response is empty"
                );
            }

            JsonNode response =
                    objectMapper.readTree(responseBody);

            if (response == null ||
                    !StringUtils.hasText(
                            response
                                    .path("customer_portal_url")
                                    .asText(null)
                    )) {
                throw new BadRequestException(
                        "Polar customer session response is missing portal URL"
                );
            }

            return new CustomerPortalSessionResponse(
                    response.path("customer_portal_url").asText()
            );

        } catch (RestClientResponseException ex) {
            throw new BadRequestException(
                    "Failed to create Polar customer portal session: " +
                            polarErrorMessage(ex)
            );
        } catch (RestClientException |
                 JsonProcessingException ex) {
            throw new BadRequestException(
                    "Failed to create Polar customer portal session: " +
                            ex.getMessage()
            );
        }
    }

    public void revokeSubscription(
            String polarSubscriptionId
    ) {

        validateAccessToken();

        if (!StringUtils.hasText(polarSubscriptionId)) {
            throw new BadRequestException(
                    "Polar subscription ID is missing"
            );
        }

        try {
            restClient()
                    .delete()
                    .uri(
                            "/subscriptions/{subscriptionId}",
                            polarSubscriptionId
                    )
                    .retrieve()
                    .toBodilessEntity();

        } catch (RestClientResponseException ex) {
            throw new BadRequestException(
                    "Failed to revoke Polar subscription: " +
                            polarErrorMessage(ex)
            );
        } catch (RestClientException ex) {
            throw new BadRequestException(
                    "Failed to revoke Polar subscription: " +
                            ex.getMessage()
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

        validateAccessToken();

        if (!StringUtils.hasText(
                polarProperties.getPremiumProductId()
        )) {
            throw new BadRequestException(
                    "Polar premium product ID is not configured"
            );
        }
    }

    private String checkoutSuccessUrl(
            CheckoutClient client
    ) {

        if (client == CheckoutClient.MOBILE) {
            return firstPresent(
                    polarProperties.getMobileCheckoutSuccessUrl(),
                    polarProperties.getCheckoutSuccessUrl()
            );
        }

        return firstPresent(
                polarProperties.getWebCheckoutSuccessUrl(),
                polarProperties.getCheckoutSuccessUrl()
        );
    }

    private String checkoutReturnUrl(
            CheckoutClient client
    ) {

        if (client == CheckoutClient.MOBILE) {
            return firstPresent(
                    polarProperties.getMobileCheckoutReturnUrl(),
                    polarProperties.getCheckoutReturnUrl()
            );
        }

        return firstPresent(
                polarProperties.getWebCheckoutReturnUrl(),
                polarProperties.getCheckoutReturnUrl()
        );
    }

    private String firstPresent(
            String preferred,
            String fallback
    ) {

        return StringUtils.hasText(preferred)
                ? preferred
                : fallback;
    }

    private void validateAccessToken() {

        if (!StringUtils.hasText(
                polarProperties.getAccessToken()
        )) {
            throw new BadRequestException(
                    "Polar access token is not configured"
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

    private String polarErrorMessage(
            RestClientResponseException ex
    ) {

        String responseBody =
                ex.getResponseBodyAsString();

        if (StringUtils.hasText(responseBody)) {
            return responseBody;
        }

        return ex.getStatusCode()
                .toString();
    }
}
