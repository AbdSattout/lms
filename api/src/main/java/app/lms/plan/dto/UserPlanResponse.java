package app.lms.plan.dto;

import app.lms.plan.enums.PlanCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record UserPlanResponse(
        Long planId,
        PlanCode code,
        String name,
        Boolean premium,
        BigDecimal xpMultiplier,
        Integer weeklyAiQuizLimit,
        Integer weeklyCourseEnrollmentLimit,
        Integer activeRoadmapFollowLimit,
        Integer randomQuizPerCourseLimit,
        Long organizationStorageLimitBytes,
        Integer organizationLimit,
        Integer organizationCourseLimit,
        Integer dailyAiToolLimit,
        LocalDateTime startedAt,
        LocalDateTime expiresAt
) {
}
