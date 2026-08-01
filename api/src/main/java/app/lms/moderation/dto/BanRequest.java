package app.lms.moderation.dto;

import jakarta.validation.constraints.NotBlank;

public record BanRequest(
        @NotBlank(message = "Reason is required")
        String reason
) {
}
