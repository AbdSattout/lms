package app.lms.billing.mapper;

import app.lms.billing.dto.SubscriptionResponse;
import app.lms.billing.model.PolarSubscription;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;

@Component
public class SubscriptionMapper {

    public SubscriptionResponse toResponse(
            PolarSubscription subscription
    ) {

        return new SubscriptionResponse(
                subscription.getStatus(),
                subscription.getCurrentPeriodStart(),
                subscription.getCurrentPeriodEnd(),
                subscription.getCancelAtPeriodEnd(),
                subscription.getCanceledAt(),
                subscription.getRevokedAt(),
                daysLeft(subscription)
        );
    }

    private Long daysLeft(
            PolarSubscription subscription
    ) {

        if (subscription.getCurrentPeriodEnd() == null) {
            return null;
        }

        if (subscription.getRevokedAt() != null) {
            return 0L;
        }

        LocalDateTime now =
                LocalDateTime.now();

        if (!subscription.getCurrentPeriodEnd()
                .isAfter(now)) {
            return 0L;
        }

        long secondsLeft =
                Duration.between(
                                now,
                                subscription.getCurrentPeriodEnd()
                        )
                        .getSeconds();

        return (secondsLeft + 86_399L) / 86_400L;
    }
}
