package app.lms.gamification.dto;

import lombok.Builder;

import java.time.LocalDate;

@Builder
public record UserStreakResponse(
        Integer currentStreak,
        Integer longestStreak,
        Integer activeDays,
        LocalDate lastActiveDate
) {
}
