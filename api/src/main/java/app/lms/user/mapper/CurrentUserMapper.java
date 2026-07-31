package app.lms.user.mapper;

import app.lms.billing.dto.SubscriptionResponse;
import app.lms.plan.dto.UserPlanResponse;
import app.lms.user.dto.CurrentUserResponse;
import app.lms.user.model.User;
import org.springframework.stereotype.Component;

@Component
public class CurrentUserMapper {

    public CurrentUserResponse toResponse(
            User user,
            UserPlanResponse plan,
            SubscriptionResponse subscription
    ) {

        return new CurrentUserResponse(
                user.getId(),
                user.getName(),
                user.getUsername(),
                user.getPicture(),
                plan,
                subscription
        );
    }
}
