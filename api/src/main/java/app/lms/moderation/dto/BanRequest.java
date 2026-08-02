package app.lms.moderation.dto;

import app.lms.moderation.enums.BanDuration;
import jakarta.validation.constraints.NotBlank;

import java.time.LocalDateTime;

public record BanRequest(
        @NotBlank(message = "Reason is required")
        String reason,
        BanDuration duration
) {

    public BanDuration resolvedDuration() {
        return duration == null
                ? BanDuration.PERMANENT
                : duration;
    }

    public LocalDateTime expiresAtFrom(
            LocalDateTime now
    ) {
        return resolvedDuration()
                .expiresAtFrom(now);
    }
}
