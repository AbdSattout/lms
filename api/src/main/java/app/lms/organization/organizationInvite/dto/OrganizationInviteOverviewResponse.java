package app.lms.organization.organizationInvite.dto;

import lombok.Builder;

@Builder
public record OrganizationInviteOverviewResponse(

        long membersCount,
        long adminsCount,
        long studentsCount,

        long coursesCount,
        long publishedCoursesCount,
        long draftCoursesCount,

        long postsCount,
        long roadmapsCount

) {}
