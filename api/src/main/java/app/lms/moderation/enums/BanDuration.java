package app.lms.moderation.enums;

import com.fasterxml.jackson.annotation.JsonCreator;

import java.time.LocalDateTime;
import java.util.Locale;

public enum BanDuration {
    DAY,
    WEEK,
    MONTH,
    YEAR,
    PERMANENT;

    @JsonCreator
    public static BanDuration fromJson(String value) {

        if (value == null || value.isBlank()) {
            return PERMANENT;
        }

        return BanDuration.valueOf(
                value.trim()
                        .toUpperCase(Locale.ROOT)
        );
    }

    public LocalDateTime expiresAtFrom(
            LocalDateTime now
    ) {

        return switch (this) {
            case DAY ->
                    now.plusDays(1);
            case WEEK ->
                    now.plusWeeks(1);
            case MONTH ->
                    now.plusMonths(1);
            case YEAR ->
                    now.plusYears(1);
            case PERMANENT ->
                    null;
        };
    }
}
