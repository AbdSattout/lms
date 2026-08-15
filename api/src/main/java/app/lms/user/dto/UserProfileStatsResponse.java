package app.lms.user.dto;

public record UserProfileStatsResponse(
        long friendsCount,
        long organizationsCount,
        long enrolledCoursesCount,
        long completedCoursesCount,
        long followingRoadmapsCount,
        long completedRoadmapsCount,
        long certificatesCount
) {
}
