package app.lms.user.dto;

import app.lms.billing.dto.SubscriptionResponse;
import app.lms.plan.dto.UserPlanResponse;

public record CurrentUserResponse(
        Long id,
        String name,
        String username,
        String picture,
        UserPlanResponse plan,
        SubscriptionResponse subscription
) {
}
