package app.lms.enrollment.dto;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.gamification.dto.GamificationAwardResponse;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record EnrollmentResponse(

        Long courseId,
        String courseTitle,
        LocalDateTime enrolledAt,
        List<GamificationAwardResponse> rewards,
        List<UserBadgeResponse> badges

) {}
