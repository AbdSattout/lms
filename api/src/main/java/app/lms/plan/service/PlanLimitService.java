package app.lms.plan.service;

import app.lms.plan.enums.PlanUsageType;
import app.lms.plan.exception.PlanLimitExceededException;
import app.lms.plan.model.Plan;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PlanLimitService {

    private final UserPlanService userPlanService;
    private final PlanUsageCounterService usageCounterService;

    public void consumeWeeklyCourseEnrollment(
            User user
    ) {

        Plan plan =
                userPlanService.currentPlan(user);

        consumeWeekly(
                user,
                PlanUsageType.COURSE_ENROLLMENT,
                plan.getWeeklyCourseEnrollmentLimit(),
                "Weekly course enrollment limit reached"
        );
    }

    private void consumeWeekly(
            User user,
            PlanUsageType type,
            Integer limit,
            String message
    ) {

        if (userPlanService.isUnlimited(limit)) {
            return;
        }

        boolean consumed =
                usageCounterService.tryIncrementWeekly(
                        user.getId(),
                        type,
                        limit
                );

        if (!consumed) {
            throw new PlanLimitExceededException(message);
        }
    }
}
