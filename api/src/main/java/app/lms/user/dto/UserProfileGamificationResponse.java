package app.lms.user.dto;

import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.enums.LevelTier;

public record UserProfileGamificationResponse(
        Integer totalXp,
        Integer levelNumber,
        String levelTitle,
        LevelTier tier,
        UserStreakResponse streak
) {
}
