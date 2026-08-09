package app.lms.notification.dto;

import jakarta.validation.constraints.NotBlank;

public record RegisterDeviceRequest(

        @NotBlank
        String token

) {
}
