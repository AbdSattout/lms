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

    public boolean reserve(
            User user,
            PlanUsageType type
    ) {

        Plan plan =
                userPlanService.currentPlan(user);

        return reserveWeekly(
                user,
                type,
                weeklyLimit(
                        plan,
                        type
                )
        );
    }

    public void release(
            User user,
            PlanUsageType type
    ) {

        usageCounterService.releaseWeekly(
                user.getId(),
                type
        );
    }

    private boolean reserveWeekly(
            User user,
            PlanUsageType type,
            Integer limit
    ) {

        if (userPlanService.isUnlimited(limit)) {
            return false;
        }

        boolean reserved =
                usageCounterService.tryIncrementWeekly(
                        user.getId(),
                        type,
                        limit
                );

        if (!reserved) {
            throw new PlanLimitExceededException(
                    limitExceededMessage(
                            type
                    )
            );
        }

        return true;
    }

    private Integer weeklyLimit(
            Plan plan,
            PlanUsageType type
    ) {

        return switch (type) {
            case AI_QUIZ -> plan.getWeeklyAiQuizLimit();
            case COURSE_ENROLLMENT -> plan.getWeeklyCourseEnrollmentLimit();
            case AI_TOOL -> plan.getWeeklyAiToolLimit();
            case RANDOM_QUIZ -> throw new IllegalArgumentException(
                    "Random quiz usage requires a course-scoped limit"
            );
        };
    }

    private String limitExceededMessage(
            PlanUsageType type
    ) {

        return switch (type) {
            case AI_QUIZ -> "Weekly AI quiz limit reached";
            case COURSE_ENROLLMENT -> "Weekly course enrollment limit reached";
            case AI_TOOL -> "Weekly AI tools limit reached";
            case RANDOM_QUIZ -> "Random quiz limit reached";
        };
    }
}
