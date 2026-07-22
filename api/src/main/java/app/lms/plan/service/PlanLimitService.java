package app.lms.plan.service;

import app.lms.plan.enums.PlanUsageType;
import app.lms.plan.enums.PlanUsageWindow;
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
            PlanUsageType type,
            Long courseId
    ) {

        Plan plan =
                userPlanService.getOrCreateCurrentPlan(user);

        return reserve(
                user,
                type,
                courseId,
                limit(
                        plan,
                        type
                ),
                usageWindow(
                        type
                )
        );
    }

    public void release(
            User user,
            PlanUsageType type,
            Long courseId
    ) {

        if (courseId != null) {
            usageCounterService.releaseCourseWeekly(
                    user.getId(),
                    type,
                    courseId
            );

            return;
        }

        releaseUserWindow(
                user,
                type,
                usageWindow(
                        type
                )
        );
    }

    private boolean reserve(
            User user,
            PlanUsageType type,
            Long courseId,
            Integer limit,
            PlanUsageWindow window
    ) {

        if (isUnlimited(limit)) {
            return false;
        }

        boolean reserved =
                courseId == null
                        ? reserveUserWindow(
                                user,
                                type,
                                limit,
                                window
                        )
                        : usageCounterService.tryIncrementCourseWeekly(
                                user.getId(),
                                type,
                                courseId,
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

    private boolean reserveUserWindow(
            User user,
            PlanUsageType type,
            Integer limit,
            PlanUsageWindow window
    ) {

        return switch (window) {
            case DAILY -> usageCounterService.tryIncrementDaily(
                    user.getId(),
                    type,
                    limit
            );
            case WEEKLY -> usageCounterService.tryIncrementWeekly(
                    user.getId(),
                    type,
                    limit
            );
        };
    }

    private void releaseUserWindow(
            User user,
            PlanUsageType type,
            PlanUsageWindow window
    ) {

        switch (window) {
            case DAILY -> usageCounterService.releaseDaily(
                    user.getId(),
                    type
            );
            case WEEKLY -> usageCounterService.releaseWeekly(
                    user.getId(),
                    type
            );
        }
    }

    private Integer limit(
            Plan plan,
            PlanUsageType type
    ) {

        return switch (type) {
            case AI_QUIZ -> plan.getWeeklyAiQuizLimit();
            case COURSE_ENROLLMENT -> plan.getWeeklyCourseEnrollmentLimit();
            case AI_TOOL -> plan.getDailyAiToolLimit();
            case RANDOM_QUIZ -> plan.getRandomQuizPerCourseLimit();
        };
    }

    private PlanUsageWindow usageWindow(
            PlanUsageType type
    ) {

        return switch (type) {
            case AI_TOOL -> PlanUsageWindow.DAILY;
            case AI_QUIZ, COURSE_ENROLLMENT, RANDOM_QUIZ -> PlanUsageWindow.WEEKLY;
        };
    }

    private String limitExceededMessage(
            PlanUsageType type
    ) {

        return switch (type) {
            case AI_QUIZ -> "Weekly AI quiz limit reached";
            case COURSE_ENROLLMENT -> "Weekly course enrollment limit reached";
            case AI_TOOL -> "Daily AI tools limit reached";
            case RANDOM_QUIZ -> "Random quiz limit reached";
        };
    }

    private boolean isUnlimited(
            Integer limit
    ) {

        return limit == null;
    }
}
