package app.lms.tests.gamification.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.time.LocalDate;

public record MonthlyAwardEmailTestRequest(
        @NotBlank
        @Email
        String email,

        @Min(1)
        Integer rank,

        @Min(0)
        Long xp,

        LocalDate premiumExpiresAt
) {
}
