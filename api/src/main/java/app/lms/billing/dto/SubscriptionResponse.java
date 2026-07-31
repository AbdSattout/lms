package app.lms.billing.dto;

import java.time.LocalDateTime;

public record SubscriptionResponse(
        String status,
        LocalDateTime currentPeriodStart,
        LocalDateTime currentPeriodEnd,
        Boolean cancelAtPeriodEnd,
        LocalDateTime canceledAt,
        LocalDateTime revokedAt,
        Long daysLeft
) {
}
