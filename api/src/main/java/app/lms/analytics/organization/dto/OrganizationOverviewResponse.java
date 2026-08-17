package app.lms.analytics.organization.dto;

import app.lms.media.dto.StorageResponse;
import app.lms.organization.enums.Visibility;
import app.lms.plan.dto.UserPlanResponse;
import app.lms.user.dto.UserResponse;
import lombok.Builder;

@Builder
public record OrganizationOverviewResponse(

        UserResponse owner,

        UserPlanResponse ownerPlan,

        Visibility visibility,

        long membersCount,
        long adminsCount,
        long studentsCount,
        long joinRequestsCount,
        long bannedUsersCount,

        long coursesCount,
        long publishedCoursesCount,
        long draftCoursesCount,

        long postsCount,

        long roadmapsCount,

        StorageResponse storage

) {}
