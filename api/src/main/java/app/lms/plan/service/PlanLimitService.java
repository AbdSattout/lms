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
                plan.getWeeklyCourseEnrollmentLimit()
        );
    }

    private void consumeWeekly(
            User user,
            Integer limit
    ) {

        if (userPlanService.isUnlimited(limit)) {
            return;
        }

        boolean consumed =
                usageCounterService.tryIncrementWeekly(
                        user.getId(),
                        PlanUsageType.COURSE_ENROLLMENT,
                        limit
                );

        if (!consumed) {
            throw new PlanLimitExceededException("Weekly course enrollment limit reached");
        }
    }
}
