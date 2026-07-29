package app.lms.plan.mapper;

import app.lms.plan.dto.UserPlanResponse;
import app.lms.plan.model.Plan;
import app.lms.plan.model.UserPlan;
import org.springframework.stereotype.Component;

@Component
public class UserPlanMapper {

    public UserPlanResponse toResponse(
            Plan plan,
            UserPlan userPlan,
            Boolean premium
    ) {

        return new UserPlanResponse(
                plan.getId(),
                plan.getCode(),
                plan.getName(),
                premium,
                plan.getXpMultiplier(),
                plan.getWeeklyAiQuizLimit(),
                plan.getWeeklyCourseEnrollmentLimit(),
                plan.getActiveRoadmapFollowLimit(),
                plan.getRandomQuizPerCourseLimit(),
                plan.getOrganizationStorageLimitBytes(),
                plan.getOrganizationLimit(),
                plan.getOrganizationCourseLimit(),
                plan.getDailyAiToolLimit(),
                userPlan != null
                        ? userPlan.getStartedAt()
                        : null,
                userPlan != null
                        ? userPlan.getExpiresAt()
                        : null
        );
    }
}
