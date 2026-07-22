package app.lms.analytics.user.dto;

import lombok.Builder;

@Builder
public record UserDashboardResponse(

        long organizationsCount,

        long enrolledCoursesCount,
        long completedCoursesCount,

        long followingRoadmapsCount,
        long completedRoadmapsCount,

        long certificatesCount,

        int totalXp,
        int currentLevel,

        int currentStreak,
        int longestStreak

) {}