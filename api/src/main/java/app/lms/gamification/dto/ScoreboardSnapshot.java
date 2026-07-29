package app.lms.gamification.dto;

import app.lms.gamification.enums.ScoreboardPeriod;

import java.time.LocalDate;
import java.util.List;

public record ScoreboardSnapshot(
        ScoreboardPeriod period,
        LocalDate from,
        LocalDate to,
        List<ScoreboardEntryResponse> rankedEntries
) {

    public boolean matches(
            LocalDate from,
            LocalDate to
    ) {

        return this.from.equals(from) &&
                this.to.equals(to);
    }
}
