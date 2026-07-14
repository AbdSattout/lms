package app.lms.gamification.dto;

import app.lms.gamification.enums.ScoreboardPeriod;
import lombok.Builder;

import java.time.LocalDate;
import java.util.List;

@Builder
public record ScoreboardResponse(
        ScoreboardPeriod period,
        LocalDate from,
        LocalDate to,
        List<ScoreboardEntryResponse> leaders,
        ScoreboardEntryResponse me
) {
}
