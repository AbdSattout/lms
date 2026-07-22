package app.lms.plan.config;

import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import app.lms.plan.repository.PlanRepository;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class DefaultPlanSeeder implements ApplicationRunner {

    private static final BigDecimal FREE_XP_MULTIPLIER =
            BigDecimal.ONE;

    private static final int FREE_WEEKLY_AI_QUIZ_LIMIT = 2;

    private static final int FREE_WEEKLY_COURSE_ENROLLMENT_LIMIT = 2;

    private static final int FREE_ACTIVE_ROADMAP_FOLLOW_LIMIT = 1;

    private static final int FREE_RANDOM_QUIZ_PER_COURSE_LIMIT = 1;

    private static final long FREE_ORGANIZATION_STORAGE_LIMIT_BYTES =
            100L * 1024 * 1024;

    private static final int FREE_ORGANIZATION_LIMIT = 1;

    private static final int FREE_DAILY_AI_TOOL_LIMIT = 10;

    private static final BigDecimal PREMIUM_XP_MULTIPLIER =
            new BigDecimal("1.20");

    private final PlanRepository planRepository;

    @Override
    @Transactional
    public void run(
            @NonNull ApplicationArguments args
    ) {

        seedFreePlan();
        seedPremiumPlan();
    }

    private void seedFreePlan() {

        if (planRepository.existsByCode(PlanCode.FREE)) {
            return;
        }

        Plan plan =
                Plan.builder()
                        .code(PlanCode.FREE)
                        .name("Free")
                        .description("Limited free plan")
                        .defaultPlan(true)
                        .xpMultiplier(FREE_XP_MULTIPLIER)
                        .weeklyAiQuizLimit(FREE_WEEKLY_AI_QUIZ_LIMIT)
                        .weeklyCourseEnrollmentLimit(
                                FREE_WEEKLY_COURSE_ENROLLMENT_LIMIT
                        )
                        .activeRoadmapFollowLimit(
                                FREE_ACTIVE_ROADMAP_FOLLOW_LIMIT
                        )
                        .randomQuizPerCourseLimit(
                                FREE_RANDOM_QUIZ_PER_COURSE_LIMIT
                        )
                        .organizationStorageLimitBytes(
                                FREE_ORGANIZATION_STORAGE_LIMIT_BYTES
                        )
                        .organizationLimit(FREE_ORGANIZATION_LIMIT)
                        .dailyAiToolLimit(FREE_DAILY_AI_TOOL_LIMIT)
                        .build();

        planRepository.save(plan);
    }

    private void seedPremiumPlan() {

        if (planRepository.existsByCode(PlanCode.PREMIUM)) {
            return;
        }

        Plan plan =
                Plan.builder()
                        .code(PlanCode.PREMIUM)
                        .name("Premium")
                        .description("Unlimited premium plan")
                        .defaultPlan(false)
                        .xpMultiplier(PREMIUM_XP_MULTIPLIER)
                        .weeklyAiQuizLimit(null)
                        .weeklyCourseEnrollmentLimit(null)
                        .activeRoadmapFollowLimit(null)
                        .randomQuizPerCourseLimit(null)
                        .organizationStorageLimitBytes(null)
                        .organizationLimit(null)
                        .dailyAiToolLimit(null)
                        .build();

        planRepository.save(plan);
    }
}
