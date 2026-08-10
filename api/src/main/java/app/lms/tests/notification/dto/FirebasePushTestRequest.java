package app.lms.tests.notification.dto;

import jakarta.validation.constraints.NotBlank;

public record FirebasePushTestRequest(

        @NotBlank
        String token,

        String title,

        String message
) {
}
