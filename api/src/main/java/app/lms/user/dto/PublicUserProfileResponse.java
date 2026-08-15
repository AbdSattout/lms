package app.lms.user.dto;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.course.dto.CourseResponse;

import java.util.List;

public record PublicUserProfileResponse(
        ProfileResponse profile,
        UserProfileFriendshipResponse friendship,
        UserProfileStatsResponse stats,
        UserProfileGamificationResponse gamification,
        List<UserBadgeResponse> badges,
        List<CourseResponse> recentCourses
) {
}
