package app.lms.billing.service;

import app.lms.billing.model.PolarSubscription;
import app.lms.billing.model.PolarWebhookEvent;
import app.lms.billing.repository.PolarSubscriptionRepository;
import app.lms.billing.repository.PolarWebhookEventRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.OffsetDateTime;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class PolarWebhookService {

    private final ObjectMapper objectMapper =
            new ObjectMapper();
    private final PolarWebhookVerifier polarWebhookVerifier;
    private final PolarSubscriptionRepository polarSubscriptionRepository;
    private final PolarWebhookEventRepository polarWebhookEventRepository;
    private final UserRepository userRepository;
    private final UserPlanBillingService userPlanBillingService;

    @Transactional
    public void handle(
            String payload,
            HttpHeaders headers
    ) {

        polarWebhookVerifier.verify(
                payload,
                headers
        );

        String webhookId =
                headers.getFirst("webhook-id");

        if (!StringUtils.hasText(webhookId)) {
            throw new BadRequestException(
                    "Polar webhook ID is missing"
            );
        }

        if (polarWebhookEventRepository.existsByWebhookId(
                webhookId
        )) {
            return;
        }

        JsonNode event =
                parsePayload(payload);

        String eventType =
                text(
                        event,
                        "type"
                );

        JsonNode data =
                event.path("data");

        processEvent(
                eventType,
                data
        );

        polarWebhookEventRepository.save(
                PolarWebhookEvent.builder()
                        .webhookId(webhookId)
                        .eventType(eventType)
                        .processedAt(LocalDateTime.now())
                        .payload(payload)
                        .build()
        );
    }

    private void processEvent(
            String eventType,
            JsonNode data
    ) {

        switch (eventType) {
            case "subscription.active",
                 "subscription.updated",
                 "subscription.canceled",
                 "subscription.revoked" ->
                    processSubscriptionEvent(
                            eventType,
                            data
                    );
            case "order.created" ->
                    processOrderCreated(data);
            default ->
                    log.info(
                            "Ignoring Polar webhook event {}",
                            eventType
                    );
        }
    }

    private void processSubscriptionEvent(
            String eventType,
            JsonNode subscription
    ) {

        User user =
                userFromSubscription(subscription);

        PolarSubscription polarSubscription =
                upsertPolarSubscription(
                        user,
                        subscription
                );

        String status =
                text(
                        subscription,
                        "status"
                );

        if ("subscription.revoked".equals(eventType)) {
            polarSubscription.setRevokedAt(
                    LocalDateTime.now()
            );
            userPlanBillingService.downgradeToFree(user);
            return;
        }

        if ("active".equals(status) ||
                "trialing".equals(status) ||
                "past_due".equals(status) ||
                "canceled".equals(status)) {
            userPlanBillingService.activatePremium(
                    user,
                    dateTime(subscription, "current_period_start"),
                    dateTime(subscription, "current_period_end")
            );
            return;
        }

        if ("unpaid".equals(status) ||
                "incomplete_expired".equals(status)) {
            polarSubscription.setRevokedAt(
                    LocalDateTime.now()
            );
            userPlanBillingService.downgradeToFree(user);
        }
    }

    private void processOrderCreated(
            JsonNode order
    ) {

        if (!order.path("paid").asBoolean(false)) {
            return;
        }

        String billingReason =
                text(
                        order,
                        "billing_reason"
                );

        if (!"subscription_create".equals(billingReason) &&
                !"subscription_cycle".equals(billingReason) &&
                !"subscription_update".equals(billingReason)) {
            return;
        }

        JsonNode subscription =
                order.path("subscription");

        if (subscription.isMissingNode() ||
                subscription.isNull()) {
            return;
        }

        processSubscriptionEvent(
                "order.created",
                subscription
        );
    }

    private PolarSubscription upsertPolarSubscription(
            User user,
            JsonNode subscription
    ) {

        String polarSubscriptionId =
                requiredText(
                        subscription,
                        "id"
                );

        PolarSubscription polarSubscription =
                polarSubscriptionRepository
                        .findByPolarSubscriptionId(
                                polarSubscriptionId
                        )
                        .orElseGet(() ->
                                PolarSubscription.builder()
                                        .user(user)
                                        .polarSubscriptionId(
                                                polarSubscriptionId
                                        )
                                        .build()
                        );

        polarSubscription.setUser(user);
        polarSubscription.setPolarCustomerId(
                requiredText(
                        subscription,
                        "customer_id"
                )
        );
        polarSubscription.setPolarProductId(
                requiredText(
                        subscription,
                        "product_id"
                )
        );
        polarSubscription.setStatus(
                requiredText(
                        subscription,
                        "status"
                )
        );
        polarSubscription.setCurrentPeriodStart(
                dateTime(subscription, "current_period_start")
        );
        polarSubscription.setCurrentPeriodEnd(
                dateTime(subscription, "current_period_end")
        );
        polarSubscription.setCancelAtPeriodEnd(
                subscription
                        .path("cancel_at_period_end")
                        .asBoolean(false)
        );
        polarSubscription.setCanceledAt(
                dateTime(subscription, "canceled_at")
        );

        return polarSubscriptionRepository.save(
                polarSubscription
        );
    }

    private User userFromSubscription(
            JsonNode subscription
    ) {

        String externalId =
                externalCustomerId(subscription);

        try {
            Long userId =
                    Long.valueOf(externalId);

            return userRepository
                    .findById(userId)
                    .orElseThrow(() ->
                            new UsernameNotFoundException(
                                    "User not found for Polar customer"
                            )
                    );

        } catch (NumberFormatException ex) {
            throw new BadRequestException(
                    "Polar customer external ID is invalid"
            );
        }
    }

    private String externalCustomerId(
            JsonNode data
    ) {

        String externalId =
                data.path("customer")
                        .path("external_id")
                        .asText(null);

        if (StringUtils.hasText(externalId)) {
            return externalId;
        }

        externalId =
                data.path("external_customer_id")
                        .asText(null);

        if (StringUtils.hasText(externalId)) {
            return externalId;
        }

        externalId =
                data.path("metadata")
                        .path("user_id")
                        .asText(null);

        if (StringUtils.hasText(externalId)) {
            return externalId;
        }

        throw new BadRequestException(
                "Polar customer external ID is missing"
        );
    }

    private JsonNode parsePayload(
            String payload
    ) {

        try {
            return objectMapper.readTree(payload);
        } catch (JsonProcessingException ex) {
            throw new BadRequestException(
                    "Invalid Polar webhook payload"
            );
        }
    }

    private String requiredText(
            JsonNode node,
            String field
    ) {

        String value =
                text(
                        node,
                        field
                );

        if (!StringUtils.hasText(value)) {
            throw new BadRequestException(
                    "Polar field is missing: " + field
            );
        }

        return value;
    }

    private String text(
            JsonNode node,
            String field
    ) {

        return node.path(field)
                .asText(null);
    }

    private LocalDateTime dateTime(
            JsonNode node,
            String field
    ) {

        String value =
                node.path(field)
                        .asText(null);

        if (!StringUtils.hasText(value)) {
            return null;
        }

        return OffsetDateTime
                .parse(value)
                .toLocalDateTime();
    }
}
