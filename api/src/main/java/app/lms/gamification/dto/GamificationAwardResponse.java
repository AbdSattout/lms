package app.lms.gamification.dto;

import app.lms.gamification.enums.XPEventType;
import lombok.Builder;

@Builder
public record GamificationAwardResponse(
        XPEventType eventType,
        Long referenceId,
        Boolean awarded,
        Integer xpAwarded,
        Integer totalXp,
        Integer previousLevelNumber,
        Integer currentLevelNumber,
        String currentLevelTitle,
        Boolean leveledUp
) {
}
