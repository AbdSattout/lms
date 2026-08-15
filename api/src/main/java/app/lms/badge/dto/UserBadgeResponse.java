package app.lms.badge.dto;

import java.time.Instant;

public record UserBadgeResponse(
        Long badgeId,
        Long userBadgeId,
        String code,
        String title,
        String description,
        String iconUrl,
        Instant earnedAt
) {
}
