package app.lms.plan.service;

import app.lms.plan.exception.PlanLimitExceededException;
import app.lms.plan.model.Plan;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.function.LongSupplier;

@Service
@RequiredArgsConstructor
public class PlanQuotaService {

    private final UserPlanService userPlanService;

    @Transactional
    public void validateActiveRoadmapFollowAllowed(
            User user,
            LongSupplier activeRoadmapFollowCount
    ) {

        Plan plan =
                userPlanService.getOrCreateCurrentPlanForUpdate(user);

        Integer limit =
                plan.getActiveRoadmapFollowLimit();

        if (isUnlimited(limit)) {
            return;
        }

        if (activeRoadmapFollowCount.getAsLong() >= limit) {
            throw new PlanLimitExceededException(
                    "Active roadmap follow limit reached"
            );
        }
    }

    private boolean isUnlimited(
            Integer limit
    ) {

        return limit == null;
    }
}
