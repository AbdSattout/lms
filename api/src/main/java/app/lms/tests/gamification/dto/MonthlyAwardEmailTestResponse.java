package app.lms.tests.gamification.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record MonthlyAwardEmailTestResponse(
        String email,
        String subject,
        Integer rank,
        Long xp,
        LocalDate premiumExpiresAt,
        LocalDateTime sentAt
) {
}
