package app.lms.plan.config;

import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import app.lms.plan.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class DefaultPlanSeeder implements ApplicationRunner {

    private static final long FREE_ORGANIZATION_STORAGE_LIMIT_BYTES =
            100L * 1024 * 1024;

    private static final int FREE_ORGANIZATION_LIMIT = 1;

    private static final int FREE_WEEKLY_AI_TOOL_LIMIT = 10;

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
                        .xpMultiplier(BigDecimal.ONE)
                        .weeklyAiQuizLimit(2)
                        .weeklyCourseEnrollmentLimit(2)
                        .activeRoadmapFollowLimit(1)
                        .randomQuizPerCourseLimit(1)
                        .organizationStorageLimitBytes(
                                FREE_ORGANIZATION_STORAGE_LIMIT_BYTES
                        )
                        .organizationLimit(FREE_ORGANIZATION_LIMIT)
                        .weeklyAiToolLimit(FREE_WEEKLY_AI_TOOL_LIMIT)
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
                        .xpMultiplier(new BigDecimal("1.50"))
                        .weeklyAiQuizLimit(null)
                        .weeklyCourseEnrollmentLimit(null)
                        .activeRoadmapFollowLimit(null)
                        .randomQuizPerCourseLimit(null)
                        .organizationStorageLimitBytes(null)
                        .organizationLimit(null)
                        .weeklyAiToolLimit(null)
                        .build();

        planRepository.save(plan);
    }
}
