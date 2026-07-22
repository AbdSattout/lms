package app.lms.dashboard.organization.dto;

import app.lms.media.dto.StorageResponse;
import app.lms.user.dto.UserResponse;
import lombok.Builder;

@Builder
public record OrganizationDashboardResponse(

        UserResponse owner,

        long membersCount,
        long adminsCount,
        long studentsCount,

        long coursesCount,
        long publishedCoursesCount,
        long draftCoursesCount,

        long postsCount,

        long roadmapsCount,

        StorageResponse storage

) {}
