package app.lms.gamification.dto;

import lombok.Builder;

@Builder
public record ScoreboardEntryResponse(
        Integer rank,
        Long userId,
        String name,
        String picture,
        Long xp,
        Integer levelNumber,
        String levelTitle
) {
}
